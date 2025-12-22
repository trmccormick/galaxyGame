# app/models/craft/satellite/base_satellite.rb
module Craft
  module Satellite
    class BaseSatellite < Craft::BaseCraft
      include CryptocurrencyMining
      include EnergyManagement  
      include BatteryManagement
      include HasMassCalculation
      include HasConstructionCosts
      include HasBlueprintPorts

      # Associations
      has_many :base_units, class_name: '::Units::BaseUnit', as: :attachable, dependent: :destroy
      has_many :units, through: :base_units, source: :itself

      has_many :base_modules, class_name: '::Modules::BaseModule', as: :attachable, dependent: :destroy

      has_many :base_rigs, class_name: '::Rigs::BaseRig', as: :attachable, dependent: :destroy

      belongs_to :orbiting_celestial_body,
                class_name: 'CelestialBodies::CelestialBody',
                optional: true

      # Callbacks
      after_create :build_units_and_modules

      # Satellite-specific methods only
      def needs_atmosphere?
        false
      end

      def valid_deployment_location?(location_type)
        location_type_s = location_type.to_s
        if operational_data.present? &&
           operational_data['deployment'].present? &&
           operational_data['deployment']['deployment_locations'].present?
          specific_locations = operational_data['deployment']['deployment_locations']
          return specific_locations.map(&:to_s).include?(location_type_s)
        end
        valid_space_locations = [
          'orbital', 'high_orbital', 'low_orbital', 'geosynchronous_orbit', 'polar_orbit',
          'equatorial_orbit', 'lagrangian_point', 'deep_space', 'asteroid_belt',
          'wormhole_proximity', 'planetary_orbit', 'satellite_orbit', 'station_orbit',
          'uncharted_system_orbit'
        ].freeze
        valid_space_locations.include?(location_type_s)
      end

      def deploy(location, options = {})
        location_type = location.to_s
        raise "Invalid deployment location" unless valid_deployment_location?(location_type)
        self.stabilizing_wormhole = options[:wormhole] if location_type == 'wormhole_proximity'
        self.orbiting_celestial_body = options[:celestial_body] if location_type.include?('orbital')
        update!(current_location: location_type, deployed: true)
      end

      def can_stabilize_wormhole?
        has_unit?('wormhole_stabilizer') || modules.any? { |mod| mod.stabilization_capable? }
      end

      def has_unit?(unit_type)
        base_units.where(unit_type: unit_type).exists?
      end

      def has_module?(module_type)
        base_modules.where(module_type: module_type).exists?
      end

      def has_rig?(rig_type)
        base_rigs.where(rig_type: rig_type).exists?
      end

      # Port checks - using the concern's get_ports_data method
      def available_unit_ports
        ports_data = get_ports_data
        
        internal = ports_data&.dig('internal_unit_ports') || 0
        external = ports_data&.dig('external_unit_ports') || 0
        propulsion = ports_data&.dig('propulsion_ports') || 0
        storage = ports_data&.dig('storage_ports') || 0
        internal + external + propulsion + storage
      end

      # def available_module_ports
      #   ports_data = get_ports_data
        
      #   internal = ports_data&.dig('internal_module_ports') || 0
      #   external = ports_data&.dig('external_module_ports') || 0
      #   internal + external
      # end

      # def available_rig_ports
      #   ports_data = get_ports_data
        
      #   internal = ports_data&.dig('internal_rig_ports') || 0
      #   external = ports_data&.dig('external_rig_ports') || 0
      #   internal + external
      # end

      # Class determination methods - these should move to concerns too
      def determine_unit_class(unit_type)
        case unit_type.to_s
        when /computer/
          Units::Computer
        else
          Units::BaseUnit
        end
      end

      # def determine_module_class(module_type)
      #   Modules::BaseModule
      # end

      # def determine_rig_class(rig_type)
      #   Rigs::BaseRig
      # end

      # Build methods from old file
      def build_units_and_modules
        base_units.destroy_all
        base_modules.destroy_all
        base_rigs.destroy_all

        craft_data = resolved_craft_data
        return unless craft_data.present?

        # === Units ===
        recommended_units = craft_data['recommended_units'] || []
        unit_port_count = available_unit_ports
        installed_units = 0

        recommended_units.each do |unit_info|
          unit_type = unit_info.is_a?(Hash) ? unit_info['id'] : unit_info.to_s
          count = unit_info.is_a?(Hash) ? (unit_info['count'] || 1) : 1
          next unless unit_type.present?
          unit_lookup_service = Lookup::UnitLookupService.new
          unit_data = unit_lookup_service.find_unit(unit_type)
          next unless unit_data.present?
          count.times do
            unit_class = determine_unit_class(unit_type)
            unit_class.create!(
              unit_type: unit_type,
              name: unit_data['name'] || unit_type.to_s.humanize,
              identifier: "#{unit_type}_#{SecureRandom.hex(4)}",
              operational_data: unit_data,
              owner: self.owner,
              attachable: self
            )
            installed_units += 1
          end
        end

        # === Modules ===
        recommended_modules = craft_data['recommended_modules'] || []
        module_port_count = available_module_ports
        installed_modules = 0

        recommended_modules.each do |mod_info|
          module_type = mod_info.is_a?(Hash) ? mod_info['id'] : mod_info.to_s
          count = mod_info.is_a?(Hash) ? (mod_info['count'] || 1) : 1
          next unless module_type.present?
          module_lookup_service = Lookup::ModuleLookupService.new
          module_data = module_lookup_service.find_module(module_type)
          next unless module_data.present?
          count.times do
            break if installed_modules >= module_port_count
            module_class = determine_module_class(module_type)
            module_class.create!(
              module_type: module_type,
              name: module_data['name'] || module_type.to_s.humanize,
              identifier: "#{module_type}_#{SecureRandom.hex(4)}",
              operational_data: module_data,
              owner: self.owner,
              attachable: self
            )
            installed_modules += 1
          end
        end

        # === Rigs ===
        recommended_rigs = craft_data['recommended_rigs'] || []
        rig_port_count = available_rig_ports
        installed_rigs = 0

        recommended_rigs.each do |rig_info|
          rig_type = rig_info.is_a?(Hash) ? rig_info['id'] : rig_info.to_s
          count = rig_info.is_a?(Hash) ? (rig_info['count'] || 1) : 1
          next unless rig_type.present?
          rig_lookup_service = Lookup::RigLookupService.new
          rig_data = rig_lookup_service.find_rig(rig_type)
          next unless rig_data.present?
          count.times do
            break if installed_rigs >= rig_port_count
            rig_class = determine_rig_class(rig_type)
            rig_class.create!(
              rig_type: rig_type,
              name: rig_data['name'] || rig_type.to_s.humanize,
              identifier: "#{rig_type}_#{SecureRandom.hex(4)}",
              operational_data: rig_data,
              owner: self.owner,
              attachable: self
            )
            installed_rigs += 1
          end
        end
      end

      def resolved_craft_data
        return operational_data if operational_data.present? && operational_data['recommended_units'].present?
        lookup_service = Lookup::CraftLookupService.new
        lookup_service.find_craft(craft_type)
      end

      def reload_operational_data
        lookup_service = Lookup::CraftLookupService.new
        craft_data = lookup_service.find_craft(craft_type)
        if craft_data
          self.operational_data = craft_data
          save!
          true
        else
          false
        end
      end

      def factory_refit!
        base_units.destroy_all
        base_modules.destroy_all
        base_rigs.destroy_all

        craft_data = resolved_craft_data
        return unless craft_data.present?

        # === Units ===
        recommended_units = craft_data.dig('recommended_fit', 'units') || []
        recommended_units.each do |unit_info|
          unit_type = unit_info['id']
          count = unit_info['count'] || 1
          unit_data = Lookup::UnitLookupService.new.find_unit(unit_type)
          next unless unit_data.present?
          count.times do
            klass = unit_type.include?('computer') ? Units::Computer : Units::BaseUnit
            klass.create!(
              unit_type: unit_type,
              name: unit_data['name'] || unit_type.humanize,
              identifier: "#{unit_type}_#{SecureRandom.hex(4)}",
              operational_data: unit_data,
              owner: self.owner,
              attachable: self
            )
          end
        end

        # === Modules ===
        recommended_modules = craft_data.dig('recommended_fit', 'modules') || []
        recommended_modules.each do |mod_info|
          module_type = mod_info['id']
          count = mod_info['count'] || 1
          module_data = Lookup::ModuleLookupService.new.find_module(module_type)
          next unless module_data.present?
          count.times do
            Modules::BaseModule.create!(
              module_type: module_type,
              name: module_data['name'] || module_type.humanize,
              identifier: "#{module_type}_#{SecureRandom.hex(4)}",
              operational_data: module_data,
              attachable: self
            )
          end
        end

        # === Rigs ===
        recommended_rigs = craft_data.dig('recommended_fit', 'rigs') || []
        recommended_rigs.each do |rig_info|
          rig_type = rig_info['id']
          count = rig_info['count'] || 1
          rig_data = Lookup::RigLookupService.new.find_rig(rig_type)
          next unless rig_data.present?
          count.times do
            Rigs::BaseRig.create!(
              rig_type: rig_type,
              name: rig_data['name'] || rig_type.humanize,
              identifier: "#{rig_type}_#{SecureRandom.hex(4)}",
              operational_data: rig_data,
              attachable: self
            )
          end
        end
      end

      def process_tick(time_skipped = 1)
        super

        # Power and battery logic
        power_balance = power_generation - power_usage
        battery_unit = base_units.find { |unit| unit.unit_type == 'satellite_battery' }
        mined_amount = 0

        if power_balance < 0 && battery_unit
          charge = battery_unit.operational_data.dig('battery', 'current_charge') || 0
          if charge >= power_usage.abs
            battery_unit.operational_data['battery']['current_charge'] = charge - power_usage.abs
            battery_unit.save!
            mined_amount = mine_gcc if respond_to?(:mine_gcc)
          end
        elsif power_balance >= 0
          mined_amount = mine_gcc if respond_to?(:mine_gcc)
          if battery_unit
            charge = battery_unit.operational_data.dig('battery', 'current_charge') || 0
            capacity = battery_unit.operational_data.dig('battery', 'capacity') || 0
            max_charge_rate = battery_unit.operational_data.dig('battery', 'max_charge_rate_kw') || 10.0
            excess_power = [power_balance, max_charge_rate].min
            battery_unit.operational_data['battery']['current_charge'] = [charge + excess_power, capacity].min
            battery_unit.save!
          end
        end

        # Deposit mined GCC
        if mined_amount && mined_amount > 0
          owner_gcc_account = Account.find_or_create_for_entity_and_currency(accountable_entity: owner, currency: Currency.find_by(symbol: 'GCC'))
          owner_gcc_account.deposit(mined_amount, "Satellite mining tick")
        end
      end

      private

      # Override the concern's default methods for satellites
      def default_blueprint_id
        'generic_satellite'  # ← This blueprint exists and has the mass data
      end

      def blueprint_category
        'satellite'
      end
    end
  end
end