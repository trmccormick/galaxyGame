require_relative '../../services/lookup/unit_lookup_service'

module Units
  class BaseUnit < ApplicationRecord
    include HasModules
    include HasRigs
    include HasStorage
    include Housing

    belongs_to :owner, polymorphic: true
    belongs_to :attachable, polymorphic: true, optional: true
    has_many :attached_units, as: :attachable, class_name: 'Units::BaseUnit'
    has_one :location, as: :locationable, class_name: 'Location::CelestialLocation'
    has_one :inventory, as: :inventoryable, dependent: :destroy

    validates :identifier, presence: true, uniqueness: true
    validates :name, :unit_type, presence: true
    validates :current_population, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

    after_initialize :load_unit_info
    after_create :initialize_unit

    attr_accessor :internal_modules, :external_modules, :rigs

    def population_capacity
      operational_data&.dig('capacity') || 0
    end

    def energy_usage
      @unit_info['consumables']['energy']
    end

    def input_resources
      @unit_info['input_resources']
    end

    def output_resources
      @unit_info['output_resources']
    end

    def collect_materials(amount)
      # Implement the logic to collect materials
    end

    def process_materials(inventory)
      # Implement the logic to process materials
    end

    def operate(resources)
      inputs = calculate_inputs(resources)
      outputs = calculate_outputs(inputs)
      handle_outputs(outputs)
    end

    def current_location
      return attachable.location if attachable.present?
      location
    end

    def process_resources(resource_name)
      Rails.logger.debug("\n=== Process Resources Start ===")
      Rails.logger.debug("Processing #{resource_name}")
      Rails.logger.debug("Initial gas buffer level: #{get_buffer_level('gas_buffer')}")
      
      return false unless operational_data && @unit_info && celestial_body
      
      # Get and verify input rate
      input_rate = @unit_info.dig('input_resources')&.find { |r| r['id'] == resource_name }&.dig('amount')
      Rails.logger.debug("Input rate: #{input_rate}")
      return false unless input_rate
      
      # Consume input material
      consumed = consume(resource_name, input_rate)
      Rails.logger.debug("Consumed material: #{consumed}")
      return false unless consumed
      
      # Get material composition
      material = Lookup::MaterialLookupService.new.find_material(resource_name)
      Rails.logger.debug("Material info: #{material.inspect}")
      return false unless material
      
      # Process outputs
      if material['smelting_output']
        material['smelting_output'].each do |output|
          material_name = output['material'].downcase
          amount = (input_rate * (output['percentage'] / 100.0)).round(3)
          Rails.logger.debug("Processing output: #{material_name} - Amount: #{amount}")
          
          case material_name
          when 'oxygen'
            stored = store_in_buffer('gas_buffer', material_name, amount)
            Rails.logger.debug("Stored in gas buffer: #{stored}")
          when 'silicon', 'iron', 'titanium'
            stored = store_in_buffer('regolith_hopper', material_name, amount)
            Rails.logger.debug("Stored in regolith hopper: #{stored}")
          end
        end
      end
      
      Rails.logger.debug("Final gas buffer level: #{get_buffer_level('gas_buffer')}")
      Rails.logger.debug("=== Process Resources End ===\n")
      
      true
    end    

    def celestial_body
      return location.celestial_body if location.present?
      return attachable&.location.celestial_body if attachable&.location.present?
      nil
    end

    def can_store?(resource_name, amount)
      return false unless inventory && compatible_storage?(resource_name)
      current_level = operational_data['storage']['current_level'] || 0
      (current_level + amount) <= storage_capacity
    end

    def current_storage_of(resource)
      inventory&.items&.where(name: resource)&.sum(:amount) || 0
    end

    def storage_capacity
      operational_data&.dig('storage', 'capacity').to_i
    end

    def storage_type
      operational_data&.dig('storage', 'type')
    end

    def store_resource(resource_name, amount)
      Rails.logger.debug("store_resource called with: #{resource_name}, #{amount}")
      Rails.logger.debug("operational_data: #{operational_data.inspect}")
    
      unless operational_data&.dig('storage', 'type')
        Rails.logger.debug("operational_data['storage']['type'] is nil")
        return false
      end
    
      unless compatible_storage?(resource_name)
        Rails.logger.debug("compatible_storage? returned false")
        return false
      end
    
      unless can_store?(resource_name, amount)
        Rails.logger.debug("can_store? returned false")
        return false
      end
    
      ensure_inventory
      item = inventory.items.find_or_initialize_by(name: resource_name)
      item.amount = (item.amount || 0) + amount
      item.owner = owner
    
      if item.save
        update_storage_levels(resource_name, amount)
        Rails.logger.debug("item saved successfully")
        true
      else
        Rails.logger.debug("item save failed")
        false
      end
    end

    def available_capacity
      max = storage_capacity
      used = operational_data['storage']['current_level'] || 0
      max - used
    end

    def remove_resource(resource_name, amount)
      current = current_storage_of(resource_name)
      return false if current < amount

      if requires_surface_storage?(resource_name)
        remove_from_surface(resource_name, amount)
      else
        remove_from_unit(resource_name, amount)
      end
    end

    def compatible_storage?(resource_name)
      storage_type = operational_data.dig('storage', 'type')
      return false unless storage_type
    
      material = Lookup::MaterialLookupService.new.find_material(resource_name)
      return false unless material
    
      # Special handling for LOX tanks - they store oxygen in liquid state
      if unit_type == 'lox_tank' && resource_name == 'oxygen'
        return true
      end
    
      case storage_type
      when 'liquid'
        material['properties']&.dig('state_at_room_temp') == 'Liquid' ||
          material['type'] == 'liquid'
      when 'gas'
        material['properties']&.dig('state_at_room_temp') == 'Gas' ||
          material['type'] == 'gas'
      when 'general'
        true
      else
        false
      end
    end

    def get_buffer_level(buffer_name)
      operational_data.dig('storage', buffer_name, 'current_level') || 0
    end

    def store_in_buffer(buffer_name, resource, amount)
      Rails.logger.debug("\n=== Store in Buffer ===")
      Rails.logger.debug("Buffer: #{buffer_name}")
      Rails.logger.debug("Resource: #{resource}")
      Rails.logger.debug("Amount: #{amount}")
      
      buffer = operational_data.dig('storage', buffer_name)
      Rails.logger.debug("Buffer data: #{buffer.inspect}")
      return false unless buffer
      
      current_level = buffer['current_level'] || 0
      new_level = current_level + amount
      Rails.logger.debug("Current level: #{current_level}")
      Rails.logger.debug("New level: #{new_level}")
      
      return false if new_level > buffer['capacity']
      
      buffer['current_level'] = new_level
      save!
      
      Rails.logger.debug("Updated buffer level: #{buffer['current_level']}")
      Rails.logger.debug("=== Store in Buffer End ===\n")
      true
    end

    private
    
    def load_unit_info
      return if unit_type.blank?
      
      @lookup_service ||= ::Lookup::UnitLookupService.new
      @unit_info = @lookup_service.find_unit(unit_type)
      
      Rails.logger.debug("Loading unit info for #{unit_type}")
      Rails.logger.debug("Found unit data: #{@unit_info.inspect}")
      
      return unless @unit_info.present?
      
      initialize_operational_data  # Initialize base structure
      initialize_storage          # Add storage configuration
      save! if persisted?
    end

    def initialize_unit
      return unless @unit_info.present?
      
      # Update production/consumption rates
      if @unit_info['generated'].present?
        self.operational_data['resources']['production_rate'] = @unit_info['generated']
      end
      
      if @unit_info['consumables'].present?
        self.operational_data['resources']['consumption_rate'] = @unit_info['consumables']
      end
      
      ensure_inventory
      save!
    end

    def initialize_operational_data
      self.operational_data = {  # Use = instead of ||=
        'modules' => { 'internal' => [], 'external' => [] },
        'rigs' => [],
        'resources' => {
          'stored' => {},
          'production_rate' => nil,
          'consumption_rate' => nil
        },
        'efficiency' => 1.0,
        'temperature' => 20,
        'maintenance_cycle' => 0,
        'storage' => {
          'type' => nil,
          'capacity' => 0,
          'current_level' => 0
        }
      }
    end

    def initialize_storage
      return unless @unit_info.present?
    
      Rails.logger.debug("=== Initialize Storage ===")
      Rails.logger.debug("Unit info: #{@unit_info.inspect}")
    
      if @unit_info['unit_type'] == 'storage' && @unit_info['capacity']
        self.operational_data['storage'] = {
          'type' => 'storage', # or maybe specify a type from the subtype
          'capacity' => @unit_info['capacity'].to_i
        }
      elsif @unit_info['type'] == 'container' && @unit_info['properties'] && @unit_info['properties']['capacity'] && @unit_info['properties']['capacity']['value']
          self.operational_data['storage'] = {
            'type' => 'container', # or maybe specify a type from the subtype
            'capacity' => @unit_info['properties']['capacity']['value'].to_i
          }
      else
        self.operational_data['storage'] = {
          'type' => nil,
          'capacity' => 0
        }
      end
    
      # Then add any specific storage buffers from unit info
      if @unit_info['storage'].is_a?(Hash)
        @unit_info['storage'].each do |buffer_name, buffer_config|
          Rails.logger.debug("Setting up buffer: #{buffer_name}")
          Rails.logger.debug("Buffer config: #{buffer_config.inspect}")
    
          self.operational_data['storage'][buffer_name] = {
            'type' => buffer_config['type'],
            'capacity' => buffer_config['capacity'],
            'current_level' => 0
          }
        end
      end
    
      Rails.logger.debug("Final storage config: #{operational_data['storage'].inspect}")
      save! if persisted?
    end

    def capacity
      operational_data&.dig('capacity') || 0
    end

    def current_population
      operational_data&.dig('current_population') || 0
    end    

    def current_modules(location)
      operational_data&.dig('modules', location.to_s) || []
    end

    def module_port_limit(location)
      @unit_info.dig('ports', location.to_s) || 0
    end

    def calculate_inputs(resources)
      inputs = {}
      input_resources.each do |input|
        resource_id = input['id']
        required = input['amount']
        inputs[resource_id] = resources.fetch(resource_id, 0) >= required ? required : 0
      end
      inputs
    end

    def calculate_outputs(inputs)
      total_input_mass = inputs.values.sum
      output_specs = output_resources.map { |output| [output['id'], output_mass(output, total_input_mass)] }.to_h
      output_specs
    end

    def output_mass(output, total_mass)
      range = output['amount_range']
      base_amount = rand(range['min']..range['max'])
      base_amount + (total_mass * 0.05).floor
    end

    def handle_outputs(outputs)
      outputs.each do |resource, amount|
        if can_store?(resource, amount)
          store_resource(resource, amount)
        else
          Rails.logger.warn("Not enough space to store #{amount} of #{resource}")
        end
      end
    end

    def consume_resources
      operational_data.dig('resources', 'consumption_rate')&.each do |resource, amount|
        consume(resource, amount)
      end
    end

    def generate_resources
      operational_data.dig('resources', 'production_rate')&.each do |resource, amount|
        store_resource(resource, amount)  # Fix: use store_resource instead of store
      end
    end

    def consume(resource, amount)
      Rails.logger.debug("===== Consume Method =====")
      Rails.logger.debug("Resource: #{resource}, Amount: #{amount}")
      Rails.logger.debug("Current operational_data: #{operational_data.inspect}")
      Rails.logger.debug("Current inventory: #{inventory.inspect}")
      
      # First verify we have enough in inventory
      current = current_storage_of(resource)
      Rails.logger.debug("Current storage: #{current}")
      return false if current < amount
    
      # Find the item in inventory
      item = inventory.items.find_by(name: resource)
      Rails.logger.debug("Found inventory item: #{item.inspect}")
      return false unless item
      
      # Update the inventory item
      item.amount -= amount
      if item.amount <= 0
        item.destroy
      else
        item.save!
      end
      Rails.logger.debug("Updated inventory item amount: #{item.amount}")
    
      # Update operational data stored resources
      stored = operational_data['resources']['stored']
      stored[resource] = (stored[resource] || 0) - amount
      save!
      Rails.logger.debug("Updated operational_data stored: #{stored.inspect}")
    
      true
    end

    def update_operational_data(key, value)
      return unless operational_data['resources']
      operational_data['resources'][key] = value
      save!
    end

    def requires_surface_storage?(resource_name)
      material = ::Lookup::MaterialLookupService.new.find_material(resource_name)
      material&.dig('storage_requirements')&.include?('surface_storage')
    end

    def store_on_surface(resource_name, amount)
      return false unless attachable&.respond_to?(:surface_storage)
      return false unless attachable.surface_storage

      attachable.surface_storage.add_pile(
        material_name: resource_name,
        amount: amount,
        source_unit: self
        )
      end
  
      def store_in_unit(resource_name, amount)
        return false unless operational_data['resources']
  
        ensure_inventory
  
        item = inventory.items.find_or_initialize_by(
          name: resource_name,
          storage_method: storage_type || 'general_storage'
        )
        item.owner = owner
        item.amount = (item.amount || 0) + amount
  
        if item.save
          update_storage_levels(resource_name, amount)
          true
        else
          false
        end
      end
  
      def remove_from_unit(resource_name, amount)
        return false unless operational_data['resources']
  
        stored = operational_data['resources']['stored']
        current = stored[resource_name].to_i
        return false if current < amount
  
        stored[resource_name] = current - amount
  
        item = inventory.items.find_by(name: resource_name)
        return false unless item
  
        if item.amount == amount
          item.destroy
        else
          item.amount -= amount
          item.save!
        end
  
        save!
        true
      end
  
      def ensure_inventory
        return if inventory
  
        build_inventory(
          capacity: operational_data.dig('storage', 'capacity'),
          storage_type: operational_data.dig('storage', 'type'),
          owner: owner
        )
      end
  
      def update_storage_levels(resource_name, amount)
        operational_data['storage']['current_level'] = (operational_data['storage']['current_level'] || 0) + amount
        operational_data['resources']['stored'][resource_name] = (operational_data['resources']['stored'][resource_name] || 0) + amount
        save!
      end

      def transfer_buffers_if_needed
        gas_buffer = operational_data.dig('storage', 'gas_buffer')
        water_buffer = operational_data.dig('storage', 'water_buffer')
        
        if gas_buffer && gas_buffer['current_level'] && gas_buffer['current_level'] >= 15
          transfer_buffer_to_settlement('gas_buffer')
        end
        
        if water_buffer && water_buffer['current_level'] && water_buffer['current_level'] >= 20
          transfer_buffer_to_settlement('water_buffer')
        end
      end
  
      def transfer_buffer_to_settlement(buffer_name)
        buffer = operational_data['storage'][buffer_name]
        return unless buffer && buffer['current_level'] > 0
        
        # Transfer to settlement inventory
        amount = buffer['current_level']
        if attachable.is_a?(BaseSettlement)
          attachable.store_resource(buffer_name == 'gas_buffer' ? 'oxygen' : 'lunar_water', amount)
        end
        
        # Reset buffer
        buffer['current_level'] = 0
        save!
      end

      def get_material_type(resource_id)
        material = Lookup::MaterialLookupService.new.find_material(resource_id)
        return nil unless material
      
        if material['properties']&.dig('state_at_room_temp') == 'Gas'
          'gas'
        elsif material['properties']&.dig('state_at_room_temp') == 'Liquid'
          'liquid'
        elsif material['storage_requirements']&.include?('surface_storage')
          'waste'
        else
          'general'
        end
      end
    end
  end