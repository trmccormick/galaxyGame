class Spacecraft
    attr_accessor :name, :fuel_capacity, :current_fuel, :crew_capacity, :current_passengers,
                  :cargo_capacity, :current_cargo, :units, :inventory, :operational_cost_per_trip,
                  :supply_needs, :waste_storage, :waste_generation_rates

    def initialize(name, fuel_capacity, crew_capacity, cargo_capacity)
        @name = name
        @fuel_capacity = fuel_capacity
        @current_fuel = fuel_capacity
        @crew_capacity = crew_capacity
        @current_passengers = 0
        @cargo_capacity = cargo_capacity
        @current_cargo = {}
        @operational_cost_per_trip = 0
        @supply_needs = { food: 0, water: 0, oxygen: 0 } # Daily needs per passenger
        @waste_storage = { solid_waste: 0, wastewater: 0, gaseous_waste: 0 }
        @waste_generation_rates = { solid_waste: 1, wastewater: 2, gaseous_waste: 0.5 } # Daily waste generation per passenger  
        @units = []
        @inventory = {
            "oxygen" => 1000,
            "water" => 500,
            "food" => 300,
            "waste_water" => 0,
            "biomass" => 0,
            "fuel" => fuel_capacity
        }
    end

    # Method to load passengers
    def load_passengers(number)
        if @current_passengers + number <= @crew_capacity
            @current_passengers += number
            puts "#{number} passengers loaded. Total passengers: #{@current_passengers}."
        else
            puts "Not enough capacity for #{number} passengers. Crew capacity is #{@crew_capacity}."
        end
    end    

    # Method to load cargo
    def load_cargo(cargo, weight)
        if current_total_cargo_weight + weight <= @cargo_capacity
            @current_cargo[cargo] = weight
            puts "#{weight} kg of #{cargo} loaded. Total cargo weight: #{current_total_cargo_weight} kg."
        else
            puts "Not enough capacity for #{weight} kg of #{cargo}. Cargo capacity is #{@cargo_capacity} kg."
        end
    end    

    # Method to calculate total cargo weight
    def current_total_cargo_weight
        @current_cargo.values.sum
    end    

    # Method to calculate supply requirements
    def calculate_supply_needs(travel_time)
        days = travel_time / 24.0
        food_needed = days * @current_passengers * @supply_needs[:food]
        water_needed = days * @current_passengers * @supply_needs[:water]
        oxygen_needed = days * @current_passengers * @supply_needs[:oxygen]
        { food: food_needed, water: water_needed, oxygen: oxygen_needed }
    end

    # Method to generate waste during travel
    def generate_waste(travel_time)
        days = travel_time / 24.0
        solid_waste = days * @current_passengers * @waste_generation_rates[:solid_waste]
        wastewater = days * @current_passengers * @waste_generation_rates[:wastewater]
        gaseous_waste = days * @current_passengers * @waste_generation_rates[:gaseous_waste]
        @waste_storage[:solid_waste] += solid_waste
        @waste_storage[:wastewater] += wastewater
        @waste_storage[:gaseous_waste] += gaseous_waste
        puts "Generated waste: #{solid_waste} kg solid, #{wastewater} liters wastewater, #{gaseous_waste} kg gaseous waste."
    end

    # Method to travel to a celestial body
    def travel_to(body)
        travel_time = body.travel_time
        fuel_needed = calculate_fuel_needed(travel_time)

        if fuel_needed > @current_fuel
            puts "Not enough fuel to travel to #{body.name}."
            return
        end

        supply_needs = calculate_supply_needs(travel_time)
        unless has_sufficient_supplies?(supply_needs)
            puts "Not enough supplies for passengers for a #{travel_time}-hour journey to #{body.name}."
            return
        end

        @current_fuel -= fuel_needed
        use_supplies(supply_needs)
        generate_waste(travel_time)
        puts "Traveling to #{body.name}. Time: #{travel_time} hours. Fuel used: #{fuel_needed}. Supplies used: #{supply_needs}."
    end

    # Method to check if sufficient supplies are available
    def has_sufficient_supplies?(supply_needs)
        supply_needs.each do |key, value|
            return false if @inventory[key].nil? || @inventory[key] < value
        end
        true
    end

    # Method to use supplies after traveling
    def use_supplies(supply_needs)
        supply_needs.each do |key, value|
            @inventory[key] -= value if @inventory[key]
        end
    end

    # Method to refuel spacecraft
    def refuel(amount)
        if @current_fuel + amount <= @fuel_capacity
            @current_fuel += amount
            puts "Refueled #{amount} liters. Current fuel: #{@current_fuel}."
        else
            puts "Cannot exceed fuel capacity."
        end
    end

    # Method to unload waste at a colony
    def unload_waste(colony)
        colony.buy_waste(@waste_storage)
        @waste_storage = { solid_waste: 0, wastewater: 0, gaseous_waste: 0 }
        puts "Waste unloaded at #{colony.name}."
    end

    private

    # Private method to calculate the fuel needed based on travel time
    def calculate_fuel_needed(hours)
        hours * 10  # Example: 10 liters of fuel per hour
    end

    # Method to add a unit to the spacecraft
    def add_unit(unit)
        @units << unit
        puts "Added #{unit.unit_type} unit with capacity #{unit.capacity}."
    end

    # Method to operate all units
    def operate_units
        @units.each do |unit|
            unit.operate(self) if unit.status == :active  # Pass in the spacecraft for inventory updates
        end
    end

    # Method to check inventory for specific resources
    def inventory_check(resource)
        @inventory[resource] || 0
    end

    # Method to use excess energy
    def use_excess_energy(excess_energy)
        @units.each do |unit|
            if unit.status == :active && excess_energy > unit.energy_consumption
                puts "Using excess energy to operate #{unit.unit_type} unit."
                unit.operate(self)
                excess_energy -= unit.energy_consumption
            end
        end
    end

    # Method to modify inventory amounts
    def modify_inventory(resource, amount)
        @inventory[resource] = (@inventory[resource] || 0) + amount
    end
end
