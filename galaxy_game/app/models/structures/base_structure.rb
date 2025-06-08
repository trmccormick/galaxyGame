module Structures
  class BaseStructure < ApplicationRecord
    # Tell Rails to use the 'structures' table instead of 'base_structures'
    self.table_name = 'structures'
    
    # Include the HasModules concern for module effects
    include HasModules
    include HasRigs
    include HasUnits
    include Housing
    include GameConstants
    include HasUnitStorage
    include HasExternalConnections

    belongs_to :settlement, class_name: 'Settlement::BaseSettlement'
    belongs_to :owner, polymorphic: true

    has_one :inventory, as: :inventoryable, dependent: :destroy
    has_many :items, through: :inventory
    
    has_one :celestial_location, as: :locationable, class_name: 'Location::CelestialLocation'

    has_many :modules, as: :attachable, class_name: 'Modules::BaseModule', dependent: :destroy
    has_many :base_units, class_name: 'Units::BaseUnit', as: :attachable
    has_many :rigs, as: :attachable, class_name: 'Rigs::BaseRig', dependent: :destroy

    validates :name, presence: true, uniqueness: true
    validates :structure_name, :structure_type, presence: true
    validates :current_population, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
    validates :operational_data, presence: true

    before_validation :load_structure_info
    after_create :create_inventory
    after_create :build_structure_shell # Only build empty shell initially

    # Core functionality methods
    def power_usage
      operational_data&.dig('consumables', 'energy_kwh') || 0
    end

    def input_resources
      operational_data&.dig('resource_management', 'consumables') || {}
    end

    def output_resources
      operational_data&.dig('resource_management', 'generated') || {}
    end

    # Unit management methods
    def build_recommended_units
      return unless operational_data&.dig('recommended_units')

      operational_data['recommended_units'].each do |unit_info|
        unit_lookup = Lookup::UnitLookupService.new
        unit_data = unit_lookup.find_unit(unit_info['id'])
        
        next unless unit_data # Skip if unit data not found
        
        unit_info['count'].times do |i|
          base_units.create!(
            identifier: "#{unit_info['id']}_#{SecureRandom.hex(4)}",
            name: "#{unit_data['name']} #{i + 1}",
            unit_type: unit_info['id'],
            owner: self,
            attachable: self,
            operational_data: unit_data
          )
        end
      end
    end

    # Module management methods
    def build_recommended_modules
      return unless operational_data&.dig('recommended_modules')

      operational_data['recommended_modules'].each do |module_info|
        module_lookup = Lookup::ModuleLookupService.new
        module_data = module_lookup.find_module(module_info['id'])
        
        next unless module_data # Skip if module data not found
        
        module_info['count'].times do |i|
          modules.create!(
            identifier: "#{module_info['id']}_#{SecureRandom.hex(4)}",
            name: "#{module_data['name']} #{i + 1}",
            module_type: module_info['id'],
            owner: self,
            attachable: self,
            operational_data: module_data
          )
        end
      end
    end

    # System operational status
    def system_status(system_name)
      operational_data&.dig('systems', system_name, 'status')
    end

    def set_system_status(system_name, status)
      return false unless operational_data&.dig('systems', system_name)
      
      operational_data['systems'][system_name]['status'] = status
      save
    end

    # Structure operational mode management
    def current_mode
      operational_data&.dig('operational_modes', 'current_mode') || 'standby'
    end

    def set_operational_mode(mode)
      return false unless available_modes.include?(mode)
      
      operational_data['operational_modes']['current_mode'] = mode
      save
    end

    def available_modes
      operational_data&.dig('operational_modes', 'available_modes')&.map { |m| m['name'] } || ['standby']
    end

    # Unit and module slot management
    def unit_slots
      unit_slots = {}
      operational_data&.dig('unit_slots')&.each do |slot|
        unit_slots[slot['type']] = slot['count']
      end
      unit_slots
    end

    def module_slots
      module_slots = {}
      operational_data&.dig('module_slots')&.each do |slot|
        module_slots[slot['type']] = slot['count']
      end
      module_slots
    end

    def available_unit_slots(unit_type)
      total = unit_slots[unit_type] || 0
      used = base_units.where(unit_type: unit_type).count
      total - used
    end

    def available_module_slots(module_type)
      total = module_slots[module_type] || 0
      used = modules.where(module_type: module_type).count
      total - used
    end

    # Installation methods for player actions
    def install_unit(unit)
      return false unless unit
      
      # Check if we have an available slot for this unit type
      return false if available_unit_slots(unit.unit_type) <= 0
      
      begin
        # Try to attach the unit
        unit.attachable = self
        success = unit.save
        
        # If that fails, try alternative approaches
        unless success
          success = unit.update(attachable: self)
          
          unless success
            unit.update_columns(
              attachable_id: self.id, 
              attachable_type: self.class.name
            )
            
            unit.reload
            success = (unit.attachable == self)
          end
        end
        
        # Update system status if successful
        update_system_status if success
        
        return success
      rescue => e
        Rails.logger.error "Error installing unit: #{e.message}"
        return false
      end
    end

    def uninstall_unit(unit)
      return false unless unit
      return false unless unit.attachable == self
      
      begin
        # Detach the unit
        unit.attachable = nil
        success = unit.save
        
        # If that fails, try alternative approaches
        unless success
          success = unit.update(attachable: nil)
          
          unless success
            unit.update_columns(
              attachable_id: nil, 
              attachable_type: nil
            )
            
            unit.reload
            success = unit.attachable.nil?
          end
        end
        
        # Update system status if successful
        update_system_status if success
        
        return success
      rescue => e
        Rails.logger.error "Error uninstalling unit: #{e.message}"
        return false
      end
    end

    # Status checking methods
    def operational?
      # A structure is operational if:
      # 1. It has all required units for basic operation
      # 2. Its power systems are online
      # 3. It's not in maintenance mode
      
      has_minimum_required_units? && 
      system_status('power_distribution') == 'online' && 
      current_mode != 'maintenance'
    end
    
    def has_recommended_units?
      return false unless operational_data&.dig('recommended_units')
      
      required_units = operational_data['recommended_units'].map do |unit_info|
        [unit_info['id'], unit_info['count']]
      end.to_h
      
      required_units.all? do |unit_type, required_count|
        actual_count = base_units.where(unit_type: unit_type).count
        actual_count >= required_count
      end
    end

    def missing_recommended_units
      return [] unless operational_data&.dig('recommended_units')
      
      required_units = operational_data['recommended_units'].map do |unit_info|
        [unit_info['id'], unit_info['count']]
      end.to_h
      
      existing_units = base_units.group(:unit_type).count
      
      missing = []
      required_units.each do |unit_type, required_count|
        existing_count = existing_units[unit_type] || 0
        missing_count = required_count - existing_count
        
        if missing_count > 0
          missing << { id: unit_type, count: missing_count }
        end
      end
      
      missing
    end

    def has_minimum_required_units?
      # For now, just ensure we have at least one power unit and one control unit
      has_power_unit = base_units.where(unit_type: POWER_UNIT_TYPES).exists?
      has_control = base_units.where(unit_type: CONTROL_UNIT_TYPES).exists?
      
      has_power_unit && has_control
    end

    # Constants for unit categories
    POWER_UNIT_TYPES = ['power_generator', 'solar_array', 'nuclear_generator'].freeze
    CONTROL_UNIT_TYPES = ['control_computer', 'facility_controller'].freeze

    private
    
    # Add these private helper methods at the end of the private section
    
    def apply_efficiency_boost(system_name, boost_value)
      return unless operational_data&.dig('systems', system_name)
      
      # Get the current efficiency value
      current_efficiency = operational_data['systems'][system_name]['efficiency_percent'] || 0
      
      # Important: Store the original value BEFORE applying the boost
      # Only store it if it hasn't been stored yet (first application)
      operational_data['systems'][system_name]['original_efficiency'] = current_efficiency unless operational_data['systems'][system_name].key?('original_efficiency')
      
      # Then apply the boost
      operational_data['systems'][system_name]['efficiency_percent'] = current_efficiency + boost_value
    end
    
    def remove_efficiency_boost(system_name, boost_value)
      return unless operational_data&.dig('systems', system_name)
      
      original_efficiency = operational_data['systems'][system_name]['original_efficiency'] || 0
      operational_data['systems'][system_name]['efficiency_percent'] = original_efficiency
      
      # Clean up tracking
      operational_data['systems'][system_name].delete('original_efficiency')
    end
    
    def apply_power_consumption_reduction(reduction_percent)
      return unless operational_data&.dig('resource_management', 'consumables', 'energy_kwh')
      
      current_rate = operational_data['resource_management']['consumables']['energy_kwh']['rate']
      original_rate = operational_data['resource_management']['consumables']['energy_kwh']['original_rate'] || current_rate
      
      # Store original for later restoration
      operational_data['resource_management']['consumables']['energy_kwh']['original_rate'] = original_rate
      
      # Apply reduction
      reduced_rate = original_rate * (1 - (reduction_percent / 100.0))
      operational_data['resource_management']['consumables']['energy_kwh']['rate'] = reduced_rate
    end
    
    def remove_power_consumption_reduction(reduction_percent)
      return unless operational_data&.dig('resource_management', 'consumables', 'energy_kwh')
      
      original_rate = operational_data['resource_management']['consumables']['energy_kwh']['original_rate']
      return unless original_rate
      
      # Restore original rate
      operational_data['resource_management']['consumables']['energy_kwh']['rate'] = original_rate
      
      # Clean up tracking
      operational_data['resource_management']['consumables']['energy_kwh'].delete('original_rate')
    end
    
    def apply_output_boost(resource_id, boost_percent)
      return unless operational_data&.dig('resource_management', 'generated', resource_id)
      
      current_rate = operational_data['resource_management']['generated'][resource_id]['rate']
      original_rate = operational_data['resource_management']['generated'][resource_id]['original_rate'] || current_rate
      
      # Store original for later restoration
      operational_data['resource_management']['generated'][resource_id]['original_rate'] = original_rate
      
      # Apply boost
      boosted_rate = original_rate * (1 + (boost_percent / 100.0))
      operational_data['resource_management']['generated'][resource_id]['rate'] = boosted_rate
    end
    
    def remove_output_boost(resource_id, boost_percent)
      return unless operational_data&.dig('resource_management', 'generated', resource_id)
      
      original_rate = operational_data['resource_management']['generated'][resource_id]['original_rate']
      return unless original_rate
      
      # Restore original rate
      operational_data['resource_management']['generated'][resource_id]['rate'] = original_rate
      
      # Clean up tracking
      operational_data['resource_management']['generated'][resource_id].delete('original_rate')
    end
    
    def apply_storage_expansion(resource_id, expansion_amount)
      # First check if we have an inventory system
      inventory_data = operational_data&.dig('inventory_capacity')
      return unless inventory_data
      
      # Find the specific resource storage capacity
      resource_capacity = inventory_data.find { |item| item['resource_id'] == resource_id }
      
      if resource_capacity
        # Store original for later
        resource_capacity['original_capacity'] ||= resource_capacity['capacity']
        
        # Apply expansion
        resource_capacity['capacity'] += expansion_amount
      else
        # Add new capacity if it doesn't exist
        inventory_data << {
          'resource_id' => resource_id,
          'capacity' => expansion_amount,
          'original_capacity' => 0
        }
      end
    end
    
    def remove_storage_expansion(resource_id, expansion_amount)
      inventory_data = operational_data&.dig('inventory_capacity')
      return unless inventory_data
      
      resource_capacity = inventory_data.find { |item| item['resource_id'] == resource_id }
      return unless resource_capacity && resource_capacity['original_capacity']
      
      # Restore original capacity
      resource_capacity['capacity'] = resource_capacity['original_capacity']
      
      # Clean up tracking
      resource_capacity.delete('original_capacity')
    end
    
    def apply_system_upgrade(system_name, properties)
      return unless operational_data&.dig('systems', system_name)
      
      # Store original properties for later restoration
      operational_data['systems'][system_name]['original_properties'] ||= 
        operational_data['systems'][system_name].except('original_properties').deep_dup
      
      # Apply each property upgrade
      properties.each do |property, value|
        operational_data['systems'][system_name][property] = value if property != 'original_properties'
      end
    end
    
    def remove_system_upgrade(system_name, properties)
      return unless operational_data&.dig('systems', system_name, 'original_properties')
      
      # Restore original properties
      original = operational_data['systems'][system_name]['original_properties']
      operational_data['systems'][system_name] = original.deep_dup
      
      # Clean up tracking
      operational_data['systems'][system_name].delete('original_properties')
    end

    private

    def load_structure_info
      # Return early if operational_data is already populated or structure_name/structure_type are missing
      return if operational_data.present? && !operational_data.empty?
      return if structure_name.blank? || structure_type.blank?
      
      Rails.logger.debug("Loading structure info for: #{structure_name}, #{structure_type}")
      @lookup_service ||= Lookup::StructureLookupService.new
      structure_data = @lookup_service.find_structure(structure_name, structure_type)
      
      unless structure_data
        errors.add(:base, "Could not find structure data for #{structure_name} of type #{structure_type}")
        return
      end
      
      self.operational_data = structure_data
      self.name ||= structure_data['name']
    end

    def build_structure_shell
      # Only create the empty structure - units will be added separately
      # Initialize systems to "not_installed" or "offline" status
      if operational_data && operational_data['systems']
        operational_data['systems'].each do |system_name, system_data|
          system_data['status'] = 'not_installed'
        end
      end
      
      # Set operational mode to standby
      if operational_data && operational_data['operational_modes']
        operational_data['operational_modes']['current_mode'] = 'standby'
      end
      
      # Initialize empty unit slots
      if operational_data && operational_data['unit_slots']
        operational_data['unit_slots'].each do |slot|
          # Make sure slot is a hash before trying to access it
          if slot.is_a?(Hash)
            slot['filled'] = 0
            slot['installed_units'] = []
          end
        end
      end
      
      save
    end

    def update_system_status
      # This method updates the status of all systems based on installed units
      return unless operational_data && operational_data['systems']
      
      # For each system, check if the required units are installed
      operational_data['systems'].each do |system_name, system_data|
        required_units = system_data['required_units'] || []
        
        if required_units.all? { |unit_type| base_units.where(unit_type: unit_type).exists? }
          system_data['status'] = 'offline'  # Units installed but not yet activated
        else
          system_data['status'] = 'not_installed'  # Missing required units
        end
      end
      
      save
    end
  end
end