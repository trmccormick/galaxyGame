module Settlement
  class BaseSettlement < ApplicationRecord
    include Housing
    include GameConstants
    include LifeSupport
    include CryptocurrencyMining
    include HasUnitStorage
    include EnergyManagement
    include FinancialManagement
    
    belongs_to :colony, class_name: 'Colony', foreign_key: 'colony_id', optional: true
    belongs_to :owner, polymorphic: true, optional: true
    has_one :account, as: :accountable, dependent: :destroy, class_name: 'Financial::Account'
    has_one :marketplace, 
          class_name: 'Market::Marketplace', 
          foreign_key: 'settlement_id', 
          dependent: :destroy

    has_one :location, 
            as: :locationable, 
            class_name: 'Location::CelestialLocation',
            dependent: :destroy

    has_many :docked_crafts,
             class_name: 'Craft::BaseCraft',
             foreign_key: :docked_at_id,
             inverse_of: :docked_at

    has_many :base_units, class_name: 'Units::BaseUnit', as: :attachable
    has_many :structures, class_name: 'Structures::BaseStructure', foreign_key: 'settlement_id'

    delegate :surface_storage, to: :inventory, allow_nil: true
    delegate :celestial_body, to: :location, allow_nil: true
    
    validates :name, presence: true
    validates :current_population, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :settlement_type, presence: true

    enum settlement_type: { base: 0, outpost: 1, settlement: 2, city: 3 }

    after_create :create_account_and_inventory
    after_update :adjust_settlement_type_based_on_population, if: :saved_change_to_current_population?
    after_create :build_units_and_modules

    # FIXED: Remove override of operational_data getter - let Rails handle it
    # The attribute accessor works fine with jsonb columns
    
    def operational_data=(value)
      self[:operational_data] = value
    end
    
    def construction_cost_percentage
      # FIXED: Simplified - operational_data will return {} for nil thanks to Rails jsonb defaults
      data = read_attribute(:operational_data) || {}
      data.dig('manufacturing', 'construction_cost_percentage') || DEFAULT_CONSTRUCTION_PERCENTAGE
    end
    
    def construction_cost_percentage=(value)
      self.operational_data ||= {}
      self.operational_data['manufacturing'] ||= {}
      self.operational_data['manufacturing']['construction_cost_percentage'] = value.to_f
    end
    
    def calculate_construction_cost(purchase_cost)
      return 0.0 if purchase_cost.nil?
      purchase_cost = purchase_cost.to_f
      (purchase_cost * construction_cost_percentage / 100.0).round(2)
    end
    
    def manufacturing_efficiency
      (operational_data || {}).dig('manufacturing', 'efficiency_bonus') || 1.0
    end
    
    def required_equipment_check_enabled?
      (operational_data || {}).dig('manufacturing', 'check_equipment') != false
    end

    # FIXED: Consistent namespace and removed duplicate method
    def npc_market_bid(resource_name)
      Market::NpcPriceCalculator.calculate_bid(self, resource_name.to_s)
    end

    def npc_buy_capacity(resource_name)
      return 0 unless account && inventory

      storage_limit = inventory.available_capacity_for?(resource_name)
      
      bid_price = npc_market_bid(resource_name)
      return 0 if bid_price <= 0

      available_cash = account.balance
      financial_limit = (available_cash / bid_price).floor
      
      [storage_limit, financial_limit].min.to_i
    end    
    
    def accessible_by?(player)
      return true if owner == player
      false
    end    

    def storage_capacity
      capacities = storage_capacity_by_type
      capacities[:liquid].to_i + capacities[:gas].to_i
    end

    def total_storage_capacity
      storage_capacity_by_type.values.sum
    end

    def capacity
      base_units.sum do |unit|
        unit.operational_data&.dig('capacity')&.to_i || 0
      end
    end

    def allocate_space(num_people)
      super(num_people)
    end

    def initialize_inventory
      initialize_storage(capacity, celestial_body) unless inventory
    end

    def establish_from_starship(starship, location)
      cargo_manifest = CargoManifestLoader.load('starship_settlement_cargo')
      verify_deployment_cargo(starship.inventory, cargo_manifest)
    
      transaction do
        settlement = create!(
          name: "#{location.name} Outpost",
          settlement_type: :outpost,
          location: location,
          owner: starship.owner
        )
    
        cargo_manifest['cargo_sections']['deployment_units'].each do |unit_data|
          deploy_unit(settlement, starship.inventory, unit_data)
        end
    
        transfer_cargo(starship.inventory, settlement.inventory, cargo_manifest)
        settlement
      end
    end

    def surface_storage?
      true
    end

    def can_store_on_surface?(item_name, amount)
      surface_storage? && 
        has_required_storage_equipment?(item_name) &&
        meets_environmental_requirements?(item_name)
    end

    def surface_storage_capacity
      Float::INFINITY
    end
    
    private
    
    def deploy_unit(settlement, inventory, unit_data)
      inventory.remove_item(unit_data['id'], 1)
      
      unit = Units::BaseUnit.create!(
        name: unit_data['name'],
        unit_type: unit_data['deployment_type'],
        identifier: "#{settlement.name}_#{unit_data['id']}_1",
        operational_data: unit_data['unit_data'],
        owner: settlement
      )
      
      settlement.base_units << unit
    end

    def deploy_housing(settlement, cargo_item)
      housing = Units::BaseUnit.create!(
        name: cargo_item.name,
        unit_type: 'housing',
        identifier: "#{settlement.name}_housing_1",
        operational_data: cargo_item.properties['unit_data'],
        owner: settlement
      )
      settlement.base_units << housing
    end

    def resource_requirements
      calculate_life_support_requirements
    end

    def check_resource_availability
      resources = resource_requirements

      if resources[:food] < current_food * STARVATION_THRESHOLD
        handle_starvation
      elsif resources[:food] > current_food
        handle_resource_shortage(:food)
      end

      if resources[:water] > current_water
        handle_resource_shortage(:water)
      end

      if resources[:energy] > current_energy
        handle_resource_shortage(:energy)
      end
    end

    def handle_starvation
      deaths = (current_population * DEATH_RATE).to_i
      self.current_population -= deaths
      self.save!
      increase_unhappiness("food", deaths)
      puts "#{deaths} people have died from starvation."
    end

    def handle_resource_shortage(resource)
      case resource
      when :food
        increase_unhappiness("food")
      when :water
        increase_unhappiness("water")
      when :energy
        increase_unhappiness("energy")
      end
    end

    def increase_unhappiness(resource, deaths = 0)
      morale_decline = MORALE_DECLINE_RATE * (current_population - deaths)
      self.morale -= morale_decline
      self.happiness -= morale_decline
      self.save!
      puts "Warning: Not enough #{resource}! Morale and happiness have declined."
    end

    def reduce_population
      self.current_population -= (current_population * 0.05).to_i
      self.save!
    end

    def add_dome(capacity, energy_consumption)
      base_units << Dome.new(capacity, energy_consumption)
    end

    def add_habitat(capacity, energy_consumption)
      base_units << Habitat.new(capacity, energy_consumption)
    end

    def create_account_and_inventory
      default_currency = Financial::Currency.find_by(symbol: 'GCC', is_system_currency: true) || Financial::Currency.first
      
      # Use exists? to check the database directly, not the unloaded association
      if default_currency && !Financial::Account.exists?(accountable: self, currency: default_currency)
        create_account!(currency: default_currency)
      end
      
      # Use exists? with correct column name: inventoryable_type (not inventoriable)
      build_inventory.save unless Inventory.exists?(inventoryable: self)
    end

    def adjust_settlement_type_based_on_population
      case current_population
      when 0..9
        self.settlement_type = :base
      when 10..99
        self.settlement_type = :outpost
      when 100..999
        self.settlement_type = :settlement
      else
        self.settlement_type = :city
      end
      save if settlement_type_changed?
    end

    def population_requirements
      case settlement_type
      when 'base'
        errors.add(:base, 'Base must have at least 1 person') if current_population < 1
      when 'outpost'
        errors.add(:base, 'Outpost must have at least 10 people') if current_population < 10
      when 'settlement'
        errors.add(:base, 'Settlement must have at least 100 people') if current_population < 100
      when 'city'
        errors.add(:base, 'City must have at least 1000 people') if current_population < 1000
      end
    end    

    def setup_initial_housing
      available_housing = inventory.items.where("properties->>'unit_class' = ?", 'Housing').first
      raise NoHousingUnitsAvailable, "Settlement requires housing units to be initialized" unless available_housing

      housing = Units::BaseUnit.create(
        name: available_housing.name,
        unit_type: "housing",
        identifier: "#{name}_housing_1",
        operational_data: JSON.parse(available_housing.properties),
        owner: self
      )

      self.base_units << housing
      inventory.remove_item(available_housing.id, 1)
    end

    def has_required_storage_equipment?(item_name)
      true
    end

    def within_labor_capacity?(amount)
      true
    end

    def meets_environmental_requirements?(item_name)
      true
    end

    def build_units_and_modules
      true
    end

    def critical_resource_threshold(resource, days: 2)
      per_person_daily =
        case resource.to_s.downcase
        when 'oxygen'
          GameConstants::HUMAN_LIFE_SUPPORT['oxygen_per_person_day']
        when 'water'
          GameConstants::HUMAN_LIFE_SUPPORT['water_per_person_day']
        when 'food'
          GameConstants::FOOD_PER_PERSON
        else
          0
        end

      (current_population * per_person_daily * days).ceil
    end
  end
end