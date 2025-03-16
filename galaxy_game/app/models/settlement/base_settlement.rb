module Settlement
  class BaseSettlement < ApplicationRecord
    include Housing
    include GameConstants
    include LifeSupport
    include HasStorage

    belongs_to :colony, class_name: 'Colony', foreign_key: 'colony_id', optional: true
    belongs_to :owner, polymorphic: true, optional: true  # Polymorphic association for ownership
    has_one :account, as: :accountable, dependent: :destroy
    has_one :ai_manager, dependent: :destroy # Add AI manager association

    has_many :base_units, 
             class_name: 'Units::BaseUnit',
             as: :attachable,
             dependent: :destroy

    has_one :inventory, as: :inventoryable, dependent: :destroy
    has_many :items, through: :inventory
    has_one :location, 
            as: :locationable, 
            class_name: 'Location::CelestialLocation',
            dependent: :destroy

    # Add docked crafts association
    has_many :docked_crafts,
             class_name: 'Craft::BaseCraft',
             foreign_key: :docked_at_id,
             inverse_of: :docked_at

    # planned adjustment for location of settlements
    # Change single location to boundary locations
    # has_many :locations, 
    #          as: :locationable, 
    #          class_name: 'Location::CelestialLocation',
    #          dependent: :destroy    

    delegate :celestial_body, to: :location, allow_nil: true
    
    validates :name, presence: true
    validates :current_population, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    enum settlement_type: { base: 0, outpost: 1, settlement: 2, city: 3 }

    validates :settlement_type, presence: true

    after_create :create_account_and_inventory
    after_update :adjust_settlement_type_based_on_population, if: :saved_change_to_current_population?

    # def central_location
    #   locations.find_by(location_type: 'center')
    # end

    # def boundary_locations
    #   locations.where(location_type: 'boundary')
    # end

    # def area
    #   # Calculate area based on boundary locations
    #   return 0 unless boundary_locations.count >= 3
    #   # Use surveyor's formula or similar for area calculation
    # end   

    def storage_capacity
      # For backward compatibility, only count liquid and gas
      capacities = storage_capacity_by_type
      capacities[:liquid].to_i + capacities[:gas].to_i
    end

    def total_storage_capacity
      # Sum all storage types
      storage_capacity_by_type.values.sum
    end

    def storage_capacity_by_type
      capacities = Hash.new(0)
      
      base_units.each do |unit|
        next unless unit.operational_data&.dig('storage')
        
        unit.operational_data['storage'].each do |type, capacity|
          next if type == 'capacity' || type == 'current_contents'
          capacities[type.to_sym] += capacity.to_i
        end
      end
      
      capacities
    end

    def capacity
      base_units.sum do |unit|
        unit.operational_data&.dig('capacity')&.to_i || 0
      end
    end

    # Collect materials from base units and update the settlement's inventory
    def collect_materials(amount)
      collected_materials = base_units.sum do |unit|
        unit.collect_materials(amount)
      end

      update_inventory(collected_materials)
    end

    # Process materials using the base units
    def process_materials
      base_units.each do |unit|
        unit.process_materials(inventory)
      end
    end

    # Allocate space for population (related to housing management)
    def allocate_space(num_people)
      super(num_people)
    end

    # Update inventory with collected materials
    def update_inventory(collected_materials)
      collected_materials.each do |material, amount|
        item = inventory.items.find_or_initialize_by(name: material)
        item.amount += amount
        item.save!
      end
    end

    # Initialize inventory if it doesn't exist
    def initialize_inventory
      initialize_storage(capacity, celestial_body) unless inventory
    end

    def establish_from_starship(starship, location)
      # Load cargo manifest
      cargo_manifest = CargoManifestLoader.load('starship_settlement_cargo')
      
      # Verify required cargo
      verify_deployment_cargo(starship.inventory, cargo_manifest)
    
      transaction do
        settlement = create!(
          name: "#{location.name} Outpost",
          settlement_type: :outpost,
          location: location,
          owner: starship.owner
        )
    
        # Deploy units from cargo
        cargo_manifest['cargo_sections']['deployment_units'].each do |unit_data|
          deploy_unit(settlement, starship.inventory, unit_data)
        end
    
        # Transfer remaining cargo to settlement inventory
        transfer_cargo(starship.inventory, settlement.inventory, cargo_manifest)
    
        settlement
      end
    end

    def surface_storage?
      true  # Base settlements always have surface storage
    end

    def can_store_on_surface?(item_name, amount)
      # No capacity limit for surface storage
      surface_storage? && 
        has_required_storage_equipment?(item_name) &&
        meets_environmental_requirements?(item_name)
    end

    def surface_storage_capacity
      Float::INFINITY  # Surface storage is effectively unlimited
    end

    private

    def deploy_unit(settlement, inventory, unit_data)
      # Remove from starship inventory
      inventory.remove_item(unit_data['id'], 1)
      
      # Create and attach unit
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

    # Check if resources are sufficient and take appropriate actions if not
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

    # Handle starvation if food is critically low
    def handle_starvation
      # 10% of the population dies due to starvation
      deaths = (current_population * DEATH_RATE).to_i
      self.current_population -= deaths
      self.save!
      increase_unhappiness("food", deaths)
      puts "#{deaths} people have died from starvation."
    end

    # Handle resource shortage by reducing population or morale
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

    # Increase unhappiness and morale decline when there's a resource shortage
    def increase_unhappiness(resource, deaths = 0)
      morale_decline = MORALE_DECLINE_RATE * (current_population - deaths)
      self.morale -= morale_decline
      self.happiness -= morale_decline
      self.save!
      puts "Warning: Not enough #{resource}! Morale and happiness have declined."
    end

    # Decrease population if resources are insufficient
    def reduce_population
      # Can use a similar logic for resource shortages, or the death rate
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
      build_account.save
      build_inventory.save
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
      # Check inventory for available housing units
      available_housing = inventory.items.where("properties->>'unit_class' = ?", 'Housing').first

      raise NoHousingUnitsAvailable, "Settlement requires housing units to be initialized" unless available_housing

      # Create unit from available housing item
      housing = Units::BaseUnit.create(
        name: available_housing.name,
        unit_type: "housing",
        identifier: "#{name}_housing_1",
        operational_data: JSON.parse(available_housing.properties),
        owner: self
      )

      # Attach to settlement and remove from inventory
      self.base_units << housing
      inventory.remove_item(available_housing.id, 1)
    end

    def has_required_storage_equipment?(item_name)
      true  # For now, assume all equipment is available
    end

    def within_labor_capacity?(amount)
      true # For now, assume unlimited labor capacity
    end

    def meets_environmental_requirements?(item_name)
      true # For now, assume all environmental requirements are met
    end
  end
end