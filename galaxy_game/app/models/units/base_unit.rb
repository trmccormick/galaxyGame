require_relative '../../services/lookup/unit_lookup_service'

module Units
  class BaseUnit < ApplicationRecord
    include HasModules
    include HasRigs
    include Housing
    include EnergyManagement

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
    after_create :create_inventory

    attr_accessor :internal_modules, :external_modules, :rigs

    delegate :storage_capacity, :storage_capacity_by_type, to: :storage_manager

    def storage_manager
      @storage_manager ||= Storage::StorageManager.new(self)
    end

    def population_capacity
      operational_data&.dig('capacity') || 0
    end

    # Update energy_usage to delegate to the concern
    def energy_usage
      power_usage
    end

    def input_resources
      @unit_info['input_resources']
    end

    def output_resources
      @unit_info['output_resources']
    end

    def collect_materials
      ensure_inventory
      
      collected_count = 0
      
      base_units.each do |unit|
        next unless unit.operational_data&.dig('resources', 'stored')
        stored = unit.operational_data['resources']['stored']
        next unless stored.present? && stored.any?
        
        Rails.logger.debug "Processing stored items: #{stored.inspect}"
        
        stored.each do |item_id, amount|
          next if amount <= 0
          
          # Create inventory item and track what was collected
          inventory.items.create!(
            name: item_id,
            amount: amount
          )
          collected_count += 1
          
          # Clear storage
          stored[item_id] = 0
        end
        
        # Reset storage level since we collected everything
        unit.operational_data['storage']['current_level'] = 0
        unit.save!
      end
      
      inventory.reload
      collected_count > 0
    end

    def process_materials(craft_inventory)
      return unless @unit_info&.dig('input_resources') && @unit_info&.dig('output_resources')
      
      Rails.logger.debug("Processing materials for unit: #{name}")
      Rails.logger.debug("Input resources required: #{@unit_info['input_resources'].inspect}")
      
      # Check if we have required input resources
      inputs = {}
      @unit_info['input_resources'].each do |input|
        resource_id = input['id']
        required = input['amount']
        available = craft_inventory.items.find_by(name: resource_id)&.amount || 0
        
        if available >= required
          inputs[resource_id] = required
        else
          Rails.logger.debug("Insufficient #{resource_id}: need #{required}, have #{available}")
          return false # Can't process without all inputs
        end
      end
      
      # Process inputs into outputs
      @unit_info['output_resources'].each do |output|
        amount = output['amount']
        
        # Store output in unit's inventory or buffers based on type
        case get_material_type(output['id'])
        when 'gas'
          store_in_buffer('gas_buffer', output['id'], amount)
        when 'liquid'
          store_in_buffer('liquid_buffer', output['id'], amount)
        else
          store_resource(output['id'], amount)
        end
      end
      
      # Consume input resources from craft inventory
      inputs.each do |resource_id, amount|
        item = craft_inventory.items.find_by(name: resource_id)
        item.decrement!(:amount, amount)
        item.destroy if item.amount <= 0
      end
      
      true
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
      return attachable&.location&.celestial_body if attachable&.location.present?
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

    def store_item(item_id, amount)
      Rails.logger.debug("store_item called with: item_id=#{item_id}, amount=#{amount}")
    
      # Initialize storage structure if needed
      self.operational_data ||= {}
      self.operational_data['storage'] ||= {
        'type' => 'general',
        'capacity' => storage_capacity || 1000,
        'current_level' => 0
      }
      self.operational_data['resources'] ||= { 'stored' => {} }
    
      Rails.logger.debug("Operational data before save: #{operational_data.inspect}")
    
      # Check capacity
      current_level = operational_data['storage']['current_level'] || 0
      capacity = operational_data['storage']['capacity'] || 1000
      return false if current_level + amount > capacity
    
      # Initialize inventory
      ensure_inventory
    
      # Update or create inventory item
      item = inventory.items.find_or_initialize_by(name: item_id)
      existing_amount = item.amount || 0
      item.amount = existing_amount + amount
      item.owner = owner
    
      Rails.logger.debug("Inventory item before save: #{item.inspect}")
    
      if item.save
        Rails.logger.debug("Inventory item saved successfully.")
    
        # Update storage data
        self.operational_data = operational_data.deep_dup # Create a new hash
        self.operational_data['resources']['stored'][item_id] = (self.operational_data['resources']['stored'][item_id] || 0) + amount
        self.operational_data['storage']['current_level'] = (self.operational_data['storage']['current_level'] || 0) + amount
        self.operational_data_will_change! # Mark operational_data as changed
    
        Rails.logger.debug("Operational data before final save: #{operational_data.inspect}")
    
        begin
          save!
          Rails.logger.debug("Unit saved successfully.")
          true
        rescue StandardError => e
          Rails.logger.error("Error saving unit: #{e.message}")
          false
        end
      else
        Rails.logger.debug("Inventory item save failed.")
        false
      end
    end

    # This method should be public or at the same visibility level as store_resource
    def update_storage_levels(resource_name, amount)
      # Initialize if needed
      self.operational_data ||= {}
      self.operational_data['resources'] ||= { 'stored' => {} }
      self.operational_data['storage'] ||= { 'current_level' => 0 }
      
      # Update the stored resources
      current = self.operational_data['resources']['stored'][resource_name] || 0
      self.operational_data['resources']['stored'][resource_name] = current + amount
      
      # Update the current storage level
      current_level = self.operational_data['storage']['current_level'] || 0
      self.operational_data['storage']['current_level'] = current_level + amount
      
      # Save the changes
      save!
    end

    private

    def load_unit_info
      return if unit_type.blank?
    
      @lookup_service ||= ::Lookup::UnitLookupService.new
      @unit_info = @lookup_service.find_unit(unit_type)
    
      return unless @unit_info.present?
    
      # Check if operational_data is already set
      if operational_data.blank?
        # Only overwrite if operational_data is empty
        self.operational_data = @unit_info.deep_dup
        save! if persisted?
      end
    end  

    def initialize_unit
      return unless @unit_info.present?
      ensure_inventory
      save!
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
      # First check if attachable has a surface_storage method and it returns something
      return false unless attachable&.respond_to?(:surface_storage)
      
      # Get the surface storage (might be nil)
      surface_store = attachable.surface_storage
      return false unless surface_store
      
      # Call add_pile on the surface storage
      surface_store.add_pile(
        material_name: resource_name,
        amount: amount,
        source_unit: self
      )
    end

    private

    def get_or_create_surface_storage
      # First try to get existing surface storage
      return attachable.inventory.surface_storage if attachable.inventory&.surface_storage
      
      # If it doesn't exist but should, create it
      if attachable.respond_to?(:inventory) && attachable.inventory.present?
        # Get celestial body from settlement or location
        celestial_body = if attachable.respond_to?(:celestial_body) && attachable.celestial_body
                           attachable.celestial_body
                         elsif attachable.respond_to?(:location) && attachable.location&.celestial_body
                           attachable.location.celestial_body
                         end
                         
        # Create surface storage if we have the needed data
        if celestial_body
          attachable.inventory.create_surface_storage!(
            celestial_body: celestial_body,
            settlement: attachable.is_a?(Settlement::BaseSettlement) ? attachable : nil
          )
          return attachable.inventory.surface_storage
        end
      end
      
      # If we can't create it, return nil
      nil
    end

    def ensure_inventory
      return inventory if inventory.present?
      
      # Create a new inventory if one doesn't exist
      inv = build_inventory
      inv.save!
      reload # Make sure we get the latest state
      inventory
    end

    def remove_from_unit(resource_name, amount)
      # Find the item in inventory
      item = inventory.items.find_by(name: resource_name)
      return false unless item
      
      # Update the inventory item
      item.amount -= amount
      if item.amount <= 0
        item.destroy
      else
        item.save!
      end
      
      # Update operational data stored resources
      stored = operational_data['resources']['stored']
      stored[resource_name] = (stored[resource_name] || 0) - amount
      
      # Update current storage level
      current_level = operational_data['storage']['current_level'] || 0
      operational_data['storage']['current_level'] = [current_level - amount, 0].max
      
      save!
      true
    end

    def remove_from_surface(resource_name, amount)
      return false unless attachable&.respond_to?(:surface_storage)
      return false unless attachable.surface_storage
      
      # Remove from surface storage
      attachable.surface_storage.remove_from_pile(
        material_name: resource_name,
        amount: amount
      )
    end
  end
end