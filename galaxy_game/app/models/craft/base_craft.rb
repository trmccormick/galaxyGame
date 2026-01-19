# app/models/craft/base_craft.rb
module Craft
  class BaseCraft < ApplicationRecord
      belongs_to :orbiting_celestial_body,
             class_name: 'CelestialBodies::CelestialBody',
             foreign_key: 'orbiting_celestial_body_id',
             inverse_of: :orbiting_craft,
             optional: true
    attribute :status, :string, default: 'operational'
    include HasModules
    include HasRigs
    include HasUnits
    include Housing
    include GameConstants # Ensure this is included to access GameConstants
    include HasUnitStorage
    include HasExternalConnections
    include EnergyManagement
    include AtmosphericProcessing
    include BatteryManagement
    include HasBlueprintPorts

    # Removed: DEFAULT_VOLUME_PER_CREW_M3 = 50.0 # Now in GameConstants

    belongs_to :player, optional: true # if the player is controlling the craft directly
    belongs_to :owner, polymorphic: true

    delegate :account, to: :owner, allow_nil: true
    delegate :under_sanction?, to: :owner, allow_nil: true # Assuming Player has this method

    has_one :inventory, as: :inventoryable, dependent: :destroy
    has_many :items, through: :inventory

    has_one :spatial_location, as: :locationable, class_name: 'Location::SpatialLocation'
    has_one :celestial_location, as: :locationable, class_name: 'Location::CelestialLocation'

    belongs_to :docked_at,
               class_name: 'Settlement::BaseSettlement',
               foreign_key: 'docked_at_id',
               inverse_of: :docked_crafts,
               optional: true

    # Add wormhole stabilization relationship
    belongs_to :stabilizing_wormhole,
               class_name: 'Wormhole',
               foreign_key: 'stabilizing_wormhole_id',
               inverse_of: :stabilizers,
               optional: true

    has_many :modules, class_name: 'Modules::BaseModule', as: :attachable, dependent: :destroy

    has_many :base_units, class_name: 'Units::BaseUnit', as: :attachable, dependent: :destroy
    has_many :units, through: :base_units, source: :base_unit # Corrected source

    has_many :rigs, as: :attachable, class_name: 'Rigs::BaseRig', dependent: :destroy

    has_one :atmosphere, foreign_key: :craft_id, dependent: :destroy

    # Delegate atmospheric methods
    delegate :pressure, :temperature, :gases, :add_gas, :remove_gas, :habitable?,
             :sealed?, :seal!, :o2_percentage, :co2_percentage,
             to: :atmosphere, allow_nil: true

    validates :name, presence: true, uniqueness: true
    validates :craft_name, :craft_type, presence: true
    validates :current_population, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
    validates :operational_data, presence: true
    validates :owner, presence: true

    before_validation :load_craft_info
    after_save :reload_associations, if: :saved_change_to_docked_at_id?
    after_create :create_inventory
    after_create :initialize_atmosphere_if_needed

    # Determines if the craft needs an atmosphere based on its operational data or installed units.
    def needs_atmosphere?
      # Check if craft is explicitly human-rated in operational data
      return true if operational_data&.dig('operational_flags', 'human_rated') == true
      
      # Check if it has life support related units in recommended_units
      if operational_data&.dig('recommended_units').is_a?(Array)
        life_support_unit_ids = [
          'starship_habitat_unit', 'waste_management_unit', 'co2_oxygen_production_unit',
          'water_recycling_unit', 'life_support_unit', 'habitat' # Added 'habitat' for common usage
        ]
        
        operational_data['recommended_units'].each do |unit|
          unit_id = unit['id'].to_s.downcase
          return true if life_support_unit_ids.any? { |ls| unit_id.include?(ls) } # Using include? for flexibility
        end
      end
      
      # Check if any existing units are life support related
      if persisted? && base_units.any?
        life_support_unit_types = [
          'habitat', 'starship_habitat', 'life_support', 
          'co2_oxygen_production', 'waste_management', 'water_recycling' # Added water_recycling
        ]
        
        return true if base_units.any? do |unit|
          life_support_unit_types.any? { |ls| unit.unit_type.to_s.downcase.include?(ls) }
        end
      end
      
      # Default to false if no human-rated indicators found
      false
    end

    # Retrieves atmospheric data for construction based on location hierarchy.
    def get_construction_atmosphere_data
      if docked_at&.respond_to?(:atmosphere) && docked_at.atmosphere
        factory_atm = docked_at.atmosphere
        {
          temperature: factory_atm.temperature,
          pressure: factory_atm.pressure,
          composition: factory_atm.composition || default_craft_composition,
          source: 'factory_inheritance'
        }
      elsif owner&.respond_to?(:current_location) && owner.current_location
        # This path assumes owner.current_location is a Location object, not just a string
        get_location_based_atmosphere
      elsif celestial_location&.respond_to?(:atmosphere)
        celestial_atm = celestial_location.atmosphere
        {
          temperature: celestial_atm.temperature || 293.15,
          pressure: celestial_atm.pressure || 101.325,
          composition: celestial_atm.composition || default_craft_composition,
          source: 'planetary_inheritance'
        }
      else
        {
          temperature: 293.15,
          pressure: 101.325,
          composition: default_craft_composition,
          source: 'default_factory'
        }
      end
    end

    # Retrieves atmospheric data based on the owner's current celestial body.
    def get_location_based_atmosphere
      if owner.respond_to?(:current_celestial_body) && owner.current_celestial_body&.atmosphere
        planetary_atm = owner.current_celestial_body.atmosphere
        {
          temperature: planetary_atm.temperature,
          pressure: planetary_atm.pressure,
          composition: planetary_atm.composition || default_craft_composition,
          source: 'location_inheritance'
        }
      else
        {
          temperature: 293.15,
          pressure: 101.325,
          composition: default_craft_composition,
          source: 'space_construction'
        }
      end
    end

    # Defines the default atmospheric composition for a craft.
    def default_craft_composition
      {
        "N2" => 78.0,
        "O2" => 21.0,
        "Ar" => 0.9,
        "CO2" => 0.04
      }
    end

    # Calculates the total atmospheric mass for the craft's internal volume.
    def calculate_atmospheric_mass_for_craft(inherited_atmosphere)
      crew_capacity = operational_data&.dig('crew_capacity') || 1
      # Use the constant from GameConstants
      volume_estimate = crew_capacity * GameConstants::DEFAULT_VOLUME_PER_CREW_M3 
      pressure_pa = inherited_atmosphere[:pressure] * 1000 # Convert kPa to Pa
      temperature_k = inherited_atmosphere[:temperature]
      gas_constant = 8.314 # J/(mol·K)
      molar_mass = 0.029 # kg/mol (average molar mass of air)

      if pressure_pa > 0 && temperature_k > 0 && volume_estimate > 0
        moles = (pressure_pa * volume_estimate) / (gas_constant * temperature_k)
        moles * molar_mass
      else
        # Fallback for invalid atmospheric data, provides a minimal mass
        crew_capacity * 1.2
      end
    end

    def input_resources
      operational_data&.dig('resources', 'input_resources')
    end

    def output_resources
      operational_data.dig('resources', 'output_resources')&.map do |resource|
        {
          'id' => resource['id'],
          'amount' => resource['amount'].to_i,
          'unit' => resource['unit']
        }
      end || [] # Ensure it returns an array even if nil
    end

    def deploy(location)
      raise 'Invalid deployment location' unless valid_deployment_location?(location)
      update!(current_location: location, deployed: true)
    end

    def fuel_capacity(fuel_type)
      tank = base_units.find_by(unit_type: "#{fuel_type}_tank")
      tank&.operational_data&.dig('storage', 'capacity') || 0
    end

    def total_mass
      blueprint = Lookup::BlueprintLookupService.new.find_blueprint("#{craft_name} Blueprint")
      return 0 unless blueprint&.dig('materials')

      blueprint['materials'].sum { |material| material['amount'] }
    end

    def craft_info
      return {} if operational_data.blank?
      operational_data
    end

    # This method is not hooked into Rails validations, it's likely for manual checks.
    def validate_required_units
      required_units = craft_info['suggested_units'] || []
      required_units.each do |unit|
        unit_count = units.where(unit_type: unit['unit_type']).count
        if unit_count < unit['min_count']
          errors.add(:base, "Missing required unit: #{unit['unit_type']} (minimum #{unit['min_count']})")
        end
      end
    end

    def dock(settlement)
      return false unless can_dock?(settlement)
      self.docked_at = settlement
      save
    end

    def undock
      self.docked_at = nil
      save
    end

    def available_storage
      storage_capacity - current_storage
    end

    def current_storage
      base_units.sum do |unit|
        unit.operational_data&.dig('current_load')&.to_i || 0
      end
    end

    def valid_deployment_location?(location_type)
      specific_locations = operational_data.dig('deployment', 'deployment_locations') ||
                            operational_data['valid_deployment_locations']

      return specific_locations.include?(location_type.to_s) if specific_locations.present?

      general_satellite_locations = ['orbital']
      general_satellite_locations.include?(location_type.to_s) || super
    end

    def operational?
      operational_data&.dig('systems', 'stabilizer_unit', 'status') == 'online'
    end

    def operational=(value)
      if value
        self.operational_data = (operational_data || {}).deep_merge({'systems' => {'stabilizer_unit' => {'status' => 'online'}}})
      else
        self.operational_data = (operational_data || {}).deep_merge({'systems' => {'stabilizer_unit' => {'status' => 'offline'}}})
      end
    end

    def location
      celestial_location || spatial_location
    end

    def set_location(location)
      if location.is_a?(Location::SpatialLocation)
        self.celestial_location&.destroy
        self.spatial_location = location
        self.current_location = location.name if location.name.present?
      elsif location.is_a?(Location::CelestialLocation)
        self.spatial_location&.destroy
        self.celestial_location = location
        self.current_location = location.name if location.name.present?
      end
      save if changed?
    end

    def recalculate_stats
      base_mining_rate = operational_data.dig('operational_properties', 'base_mining_rate_gcc_per_hour') || 0

      # Sum mining boosts from computers
      computer_units = base_units.select { |u| u.unit_type.include?('computer') }
      computer_boost = computer_units.sum { |u| u.operational_data.dig('operational_properties', 'mining_boost_gcc_per_hour').to_f }

      # Apply GPU rig boost to each computer
      gpu_rigs = rigs.select { |r| r.rig_type == 'gpu_coprocessor_rig' }
      gpu_boost = gpu_rigs.sum { |r| r.operational_data.dig('operational_properties', 'processing_boost_gcc_per_hour').to_f }
      rigged_computer_boost = computer_units.count * gpu_boost

      total_mining_rate = base_mining_rate + computer_boost + rigged_computer_boost

      # Ensure operational_properties exists
      operational_data['operational_properties'] ||= {}
      operational_data['operational_properties']['current_mining_rate_gcc_per_hour'] = total_mining_rate.round(2)
      save!
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
      true
    end

    # Constants for unit categories - using only existing unit types
    # These are now also provided by EnergyManagement module, but keeping for broader clarity
    POWER_UNIT_TYPES = EnergyManagement::POWER_UNIT_TYPES
    NAVIGATION_UNIT_TYPES = ['raptor_engine'].freeze
    CONTROL_UNIT_TYPES = ['life_support'].freeze # Consider if 'life_support' is a unit or a module

    def has_cargo_bay?
      base_units.where(unit_type: ['cargo_bay', 'storage_module']).exists?
    end

    def has_mining_equipment?
      base_units.where(unit_type: ['mining_laser', 'drill_unit', 'excavator']).exists?
    end

    def has_weapons?
      base_units.where(unit_type: ['laser_cannon', 'missile_bay', 'rail_gun']).exists?
    end

    def can_operate?
      has_minimum_required_units? && has_sufficient_power?
    end

    def load_variant_configuration(variant_id = nil)
      variant_manager = Craft::VariantManager.new(craft_type)
      variant_id ||= self.variant_configuration || 'standard'
      variant_data = variant_manager.get_variant(variant_id)
      return false unless variant_data

      self.operational_data = variant_data
      update_column(:operational_data, variant_data) if persisted?
      true
    end

    def change_variant(variant_id)
      return false unless load_variant_configuration(variant_id)
      true
    end

    def available_variants
      Craft::VariantManager.new(craft_type).available_variants
    end

    def build_units_and_modules
      Rails.logger.debug "Delegating unit/module building to UnitModuleAssemblyService for #{craft_name} (#{id})"
      UnitModuleAssemblyService.build_units_and_modules(
        target: self, 
        settlement_inventory: self.inventory || (self.docked_at&.inventory if self.docked_at)
      )
    end

    def deployment_status
      operational_data.dig('deployment_status') || 'unknown'
    end

    def deployment_status=(value)
      self.operational_data ||= {}
      self.operational_data['deployment_status'] = value
    end

    def process_tick(time_skipped = 1)
      # General per-tick logic for all crafts
      base_units.each { |unit| unit.process_tick(time_skipped) if unit.respond_to?(:process_tick) }
      modules.each { |mod| mod.process_tick(time_skipped) if mod.respond_to?(:process_tick) }
      rigs.each { |rig| rig.process_tick(time_skipped) if rig.respond_to?(:process_tick) }
      # Craft-specific logic (override in subclasses)
    end

    private

    def can_dock?(settlement)
      true # Placeholder logic, implement actual docking rules here
    end

    def load_craft_info
      return if operational_data.present? && !operational_data.empty?
      return if craft_name.blank? || craft_type.blank?

      Rails.logger.debug("Loading craft info for: #{craft_name}, #{craft_type}")
      @lookup_service ||= Lookup::CraftLookupService.new
      craft_data = @lookup_service.find_craft(craft_type)

      unless craft_data
        errors.add(:base, "Could not find craft data for #{craft_name} of type #{craft_type}")
        return
      end

      self.operational_data = craft_data
      self.name ||= craft_data['name']
    end

    def has_compatible_storage_unit?(material_type)
      base_units.any? { |unit| unit.unit_type == 'storage' } # Generic check
    end

    def reload_associations
      docked_at&.reload
    end

    # These private methods for creating/attaching units/modules are likely
    # internal helpers for other methods like `build_units_and_modules`.
    # They should not duplicate the public `install_unit`/`uninstall_unit` from concerns.
    def create_unit_from_data(unit_data)
      base_units.create!(
        identifier: SecureRandom.uuid,
        name: unit_data['id'].to_s.titleize,
        unit_type: unit_data['id'],
        owner: self,
        attachable: self
      )
    end

    def create_unit_from_type(unit_type:, name_suffix: '')
      unit_data = Lookup::UnitLookupService.new.find_unit(unit_type)
      return unless unit_data

      unit = Units::BaseUnit.create!(
        identifier: "#{unit_type}_#{SecureRandom.hex(4)}",
        name: "#{unit_data['name']} #{name_suffix}",
        unit_type: unit_type,
        owner: owner,
        operational_data: unit_data
      )
      unit
    end

    def attach_unit(unit)
      return unless unit
      unit.update!(attachable: self)
    end

    def create_module_from_type(module_type:)
      module_data = Lookup::ModuleLookupService.new.find_module(module_type)
      return unless module_data

      mod = Modules::BaseModule.create!(
        identifier: "#{module_type}_#{SecureRandom.hex(4)}",
        name: module_data['name'],
        module_type: module_type,
        owner: owner,
        attachable: self,
        operational_data: module_data
      )
      mod
    end

    def debug_unit_attachment_state
      Rails.logger.debug "Current unit attachment state for craft #{id}:"
      base_units.each do |unit|
        Rails.logger.debug "Unit #{unit.id} (#{unit.name}): attachable_id=#{unit.attachable_id}, attachable_type=#{unit.attachable_type}"
      end
    end

    # Removed duplicate install_module/uninstall_module methods as HasModules concern should provide them.
    # def install_module(mod) ... end
    # def uninstall_module(mod) ... end

    def initialize_atmosphere_if_needed
      return if atmosphere.present? # Skip if already has atmosphere
      
      unless needs_atmosphere?
        Rails.logger.debug "Skipping atmosphere creation for #{name} - not needed"
        return
      end

      Rails.logger.debug "Creating atmosphere for #{name} - human rated craft"
      
      inherited_atmosphere = get_construction_atmosphere_data

      # Create atmosphere with safe default values
      create_atmosphere!(
        environment_type: 'artificial',
        temperature: inherited_atmosphere[:temperature] || 293.15, # ~20°C if nil
        pressure: inherited_atmosphere[:pressure] || 101.325, # Standard pressure if nil
        composition: inherited_atmosphere[:composition]&.dup || default_craft_composition,
        sealing_status: true,
        total_atmospheric_mass: calculate_atmospheric_mass_for_craft(inherited_atmosphere),
        base_values: {
          'original_pressure' => inherited_atmosphere[:pressure] || 101.325,
          'original_temperature' => inherited_atmosphere[:temperature] || 293.15,
          'source' => inherited_atmosphere[:source] || 'default'
        }
      )
    end

    private

    def default_blueprint_id
      'generic_craft'
    end

    def blueprint_category
      'craft'
    end

end
end
