# app/models/craft/base_craft.rb
module Craft
  class BaseCraft < ApplicationRecord
    include HasModules
    include HasRigs
    include HasUnits
    include Housing
    include GameConstants
    include HasUnitStorage
    include HasExternalConnections
    include EnergyManagement    # <--- Corrected, now only one inclusion
    include AtmosphericProcessing
    include BatteryManagement   # <--- ADDED: For managing the craft's internal battery
    include RechargeBehavior    # <--- ADDED: For behavior related to recharging the battery

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

    # all the existing associations...
    has_many :base_units, class_name: 'Units::BaseUnit', as: :attachable
    has_many :units,      through: :base_units, source: :itself

    has_many :rigs, as: :attachable, class_name: 'Rigs::BaseRig', dependent: :destroy

    # ✅ Add atmosphere for life support
    has_one :atmosphere, foreign_key: :craft_id, dependent: :destroy

    # ✅ Delegate atmospheric methods
    delegate :pressure, :temperature, :gases, :add_gas, :remove_gas, :habitable?,
             :sealed?, :seal!, :o2_percentage, :co2_percentage,
             to: :atmosphere, allow_nil: true

    validates :name, presence: true, uniqueness: true
    validates :craft_name, :craft_type, presence: true
    validates :current_population, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
    validates :operational_data, presence: true

    before_validation :load_craft_info
    after_save :reload_associations, if: :saved_change_to_docked_at_id?
    # after_create :build_units_and_modules
    after_create :create_inventory
    after_create :initialize_atmosphere_if_needed

    def needs_atmosphere?
      # Check if craft is explicitly human-rated in operational data
      return true if operational_data&.dig('operational_flags', 'human_rated') == true
      
      # Check if it has life support related systems in recommended fit
      if operational_data&.dig('recommended_fit')
        # Check modules
        if operational_data['recommended_fit']['modules'].is_a?(Array)
          life_support_modules = [
            'life_support_module', 'co2_scrubber', 'air_filtration', 
            'oxygen', 'airlock', 'habitat'
          ]
          
          operational_data['recommended_fit']['modules'].each do |mod|
            mod_id = mod['id'].to_s.downcase
            return true if life_support_modules.any? { |ls| mod_id.include?(ls) }
          end
        end
        
        # Check units
        if operational_data['recommended_fit']['units'].is_a?(Array)
          life_support_units = [
            'habitat', 'life_support', 'oxygen', 'co2', 'water_recycling',
            'waste_management'
          ]
          
          operational_data['recommended_fit']['units'].each do |unit|
            unit_id = unit['id'].to_s.downcase
            return true if life_support_units.any? { |ls| unit_id.include?(ls) }
          end
        end
      end
      
      # Check if any existing units are life support related
      if persisted? && base_units.any?
        life_support_unit_types = [
          'habitat', 'starship_habitat', 'life_support', 
          'co2_oxygen_production', 'waste_management'
        ]
        
        return true if base_units.any? do |unit|
          life_support_unit_types.any? { |ls| unit.unit_type.to_s.downcase.include?(ls) }
        end
      end
      
      # Default to false if no human-rated indicators found
      false
    end

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
        get_location_based_atmosphere
      elsif location&.respond_to?(:atmosphere)
        celestial_atm = location.atmosphere
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

    def default_craft_composition
      {
        "N2" => 78.0,
        "O2" => 21.0,
        "Ar" => 0.9,
        "CO2" => 0.04
      }
    end

    def calculate_atmospheric_mass_for_craft(inherited_atmosphere)
      crew_capacity = operational_data&.dig('crew_capacity') || 1
      volume_estimate = crew_capacity * 50
      pressure_pa = inherited_atmosphere[:pressure] * 1000
      temperature_k = inherited_atmosphere[:temperature]
      gas_constant = 8.314
      molar_mass = 0.029

      if pressure_pa > 0 && temperature_k > 0 && volume_estimate > 0
        moles = (pressure_pa * volume_estimate) / (gas_constant * temperature_k)
        moles * molar_mass
      else
        crew_capacity * 1.2
      end
    end

    def input_resources
      operational_data&.dig('resources', 'input_resources')
    end

    def output_resources
      craft_info['output_resources'].map do |resource|
        {
          'id' => resource['id'],
          'amount' => resource['amount'].to_i,
          'unit' => resource['unit']
        }
      end
    end

    def deploy(location)
      raise 'Invalid deployment location' unless valid_deployment_location?(location)
      update!(current_location: location, deployed: true)
    end

    # def build_recommended_units
    #   return unless operational_data&.dig('recommended_units')
      
    #   UnitModuleAssemblyService.build_units_and_modules(
    #     target: self,
    #     settlement_inventory: self.inventory
    #   )
    # end

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

    def install_unit(unit)
      return false unless unit

      begin
        unit.attachable = self
        success = unit.save

        unless success
          success = unit.update(attachable: self)
          unless success
            unit.update_columns(attachable_id: self.id, attachable_type: self.class.name)
            unit.reload
            success = (unit.attachable == self)
          end
        end

        recalculate_stats if success
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
        unit.attachable = nil
        success = unit.save

        unless success
          success = unit.update(attachable: nil)
          unless success
            unit.update_columns(attachable_id: nil, attachable_type: nil)
            unit.reload
            success = unit.attachable.nil?
          end
        end

        recalculate_stats if success
        return success
      rescue => e
        Rails.logger.error "Error uninstalling unit: #{e.message}"
        return false
      end
    end

    def recalculate_stats
      Rails.logger.debug "Recalculating stats for craft #{id}"
      true
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
    CONTROL_UNIT_TYPES = ['life_support'].freeze

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
      has_minimum_required_units? && has_sufficient_power? # `has_sufficient_power?` is from EnergyManagement
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

    private

    def can_dock?(settlement)
      true
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
      base_units.any? { |unit| unit.unit_type == 'storage' }
    end

    def reload_associations
      docked_at&.reload
    end

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

    def install_module(mod)
      return false unless mod.is_a?(Modules::BaseModule)
      mod.update(attachable: self)
      reload
      true
    rescue => e
      Rails.logger.error "Failed to install module: #{e.message}"
      false
    end

    def uninstall_module(mod)
      return false unless mod.is_a?(Modules::BaseModule) && mod.attachable == self
      mod.update(attachable: nil)
      reload
      true
    rescue => e
      Rails.logger.error "Failed to uninstall module: #{e.message}"
      false
    end

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
  end
end