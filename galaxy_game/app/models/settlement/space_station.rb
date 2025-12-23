# app/models/settlement/space_station.rb
module Settlement
  class SpaceStation < BaseSettlement
    include LifeSupport
    include Docking
    include Structures::Shell
    
    has_many :storage_units, class_name: 'Units::BaseUnit', as: :attachable
    has_many :docked_crafts, class_name: 'Craft::BaseCraft', foreign_key: :docked_at_id, inverse_of: :docked_at, dependent: :destroy
    has_one :atmosphere, as: :structure, dependent: :destroy
    
    # Shell construction attributes
    attribute :panel_type, :string
    attribute :construction_start_date, :datetime
    
    validates :settlement_type, inclusion: { in: %w[station outpost] }
    
    after_initialize :set_defaults, if: :new_record?
    after_create :initialize_core_systems
    after_update :trigger_shell_callbacks, if: :saved_change_to_operational_data?
    
    def shell_status
      operational_data&.dig('shell', 'status') || 'planned'
    end
    
    def shell_status=(value)
      self.operational_data ||= {}
      self.operational_data['shell'] ||= {}
      old_value = self.operational_data['shell']['status']
      self.operational_data['shell']['status'] = value
      operational_data_will_change! if old_value != value
    end
    
    def operational?
      shell_operational?
    end
    
    def damaged?
      shell_status == 'damaged'
    end
    
    def width_m
      operational_data&.dig('dimensions', 'width_m') || 100.0
    end
    
    def length_m
      operational_data&.dig('dimensions', 'length_m') || 100.0
    end
    
    def diameter_m
      operational_data&.dig('dimensions', 'diameter_m')
    end
    
    def set_dimensions(width: nil, length: nil, diameter: nil)
      self.operational_data ||= {}
      self.operational_data['dimensions'] ||= {}
      
      self.operational_data['dimensions']['width_m'] = width if width
      self.operational_data['dimensions']['length_m'] = length if length
      self.operational_data['dimensions']['diameter_m'] = diameter if diameter
      
      save!
    end
    
    def calculate_volume
      if diameter_m.present?
        Math::PI * (diameter_m / 2.0) ** 2 * (length_m || 100.0)
      else
        height = operational_data&.dig('dimensions', 'height_m') || 50.0
        width_m * length_m * height
      end
    end
    
    def calculate_storage_capacity
      return 0.0 unless base_units.loaded? || persisted?
      
      base_units
        .select { |unit| unit.operational_data.dig('storage', 'capacity').present? }
        .sum { |unit| unit.operational_data.dig('storage', 'capacity').to_f }
    end
    
    def total_storage_capacity
      calculate_storage_capacity
    end
    
    def available_capacity
      total_storage_capacity - current_inventory_mass
    end
    
    def current_inventory_mass
      return 0.0 unless inventory
      inventory.items.sum(:amount)
    end
    
    def can_store?(mass)
      available_capacity >= mass
    end
    
    def add_module(module_type:, module_config:, owner:)
      raise "Station must be operational to add modules" unless operational?
      
      Units::BaseUnit.create!(
        attachable: self,
        owner: owner,
        unit_type: module_type,
        name: module_config[:name],
        identifier: module_config[:identifier] || SecureRandom.uuid,
        operational_data: module_config[:operational_data] || {}
      )
    end
    
    def modules_of_type(module_type)
      base_units.where(unit_type: module_type)
    end
    
    def habitat_modules
      modules_of_type('habitat')
    end
    
    def storage_modules
      modules_of_type('storage')
    end
    
    def laboratory_modules
      modules_of_type('laboratory')
    end
    
    def habitat_capacity
      habitat_modules.sum do |module_unit|
        module_unit.operational_data.dig('life_support', 'capacity').to_i
      end
    end
    
    def research_efficiency
      laboratory_modules.sum do |module_unit|
        module_unit.operational_data.dig('research', 'efficiency').to_f
      end
    end
    
    def fully_operational?
      shell_operational? && 
        life_support_operational? && 
        power_systems_operational? &&
        habitat_modules.any?
    end
    
    def life_support_operational?
      habitat_modules.any? do |mod|
        mod.operational_data.dig('life_support', 'status') == 'operational'
      end
    end
    
    def power_systems_operational?
      true
    end
    
    def station_status
      {
        name: name,
        construction_status: shell_status,
        shell_sealed: sealed?,
        shell_pressurized: pressurized?,
        population: current_population,
        habitat_capacity: habitat_capacity,
        storage_capacity: total_storage_capacity,
        available_storage: available_capacity,
        power_generation: total_power_generation,
        modules: {
          habitat: habitat_modules.count,
          storage: storage_modules.count,
          laboratory: laboratory_modules.count,
          total: base_units.count
        },
        operational: fully_operational?,
        life_support: life_support_operational?,
        power: power_systems_operational?,
        shell_health: shell_status_report
      }
    end
    
    def apply_damage(severity = :minor)
      return false unless operational?
      
      case severity
      when :minor
        unit = base_units.sample
        if unit
          unit.operational_data['status'] = 'damaged'
          unit.save!
        end
      when :major
        base_units.sample(3).each do |m|
          m.operational_data['status'] = 'damaged'
          m.save!
        end
        simulate_panel_degradation(365)
      when :critical
        self.shell_status = 'damaged'
        save!
      end
      
      true
    end
    
    def repair!(repair_shell: true)
      return false unless damaged?
      
      base_units.each do |unit|
        if unit.operational_data['status'] == 'damaged'
          unit.operational_data['status'] = 'operational'
          unit.save!
        end
      end
      
      if repair_shell
        shell_composition.each do |panel_type, data|
          repair_panels(panel_type, data['failed_count']) if data['failed_count'].to_i > 0
        end
      end
      
      self.shell_status = 'operational'
      save!
      
      true
    end
    
    def add_ship_to_hangar(ship)
      Rails.logger.warn "add_ship_to_hangar is deprecated."
      false
    end

    def remove_ship_from_hangar(ship)
      Rails.logger.warn "remove_ship_from_hangar is deprecated."
      false
    end
    
    private
    
    def trigger_shell_callbacks
      changes = saved_changes['operational_data']
      return unless changes
      
      old_data = changes[0] || {}
      new_data = changes[1] || {}
      
      old_status = old_data.dig('shell', 'status')
      new_status = new_data.dig('shell', 'status')
      
      return if old_status == new_status
      
      case new_status
      when 'sealed'
        on_shell_sealed
      when 'pressurized'
        on_shell_pressurized  
      when 'operational'
        on_shell_operational
      end
    end
    
    def on_shell_sealed
      # Shell is sealed, but atmosphere is created when units are pressurized
    end
    
    def on_shell_pressurized
      # Hook for pressurization
    end
    
    def on_shell_operational
      # Shell becomes operational, but atmosphere is created when units are pressurized
    end
    
    def set_defaults
      self.shell_status ||= 'planned'
      self.settlement_type ||= 'station'
      self.operational_data ||= {}
    end
    
    def initialize_core_systems
      create_account_and_inventory unless inventory
    end
    
    def initialize_default_modules
    # No default modules are initialized for SpaceStation. Modules must be constructed elsewhere per domain logic.
    # This method is intentionally left blank or can be removed if not required.
    end
  end
end