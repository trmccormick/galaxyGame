require 'rails_helper'

class LunarBaseSimulation
  attr_accessor :resources, :base, :crew, :crew_capacity, :power, :oxygen, :water, :food, :current_month

  def initialize
    # Define initial resources (fuel, metals, water, food, power, oxygen)
    @resources = { fuel: 1000, metals: 500, water: 200, food: 150, power: 0, oxygen: 0 }
    @base = { modules: [], power: 0, oxygen: 0 }
    @crew = 6  # Start with 6 crew members
    @crew_capacity = 12  # Capacity increases with the second starship
    @power = 0
    @oxygen = 0
    @water = 0
    @food = 0
    @current_month = 0
  end

  def create_craft
    # Create the Starship and link it to a location
    lunar_surface = Location::CelestialLocation.find_or_create_by(name: 'Lunar Surface') do |location|
      location.coordinates = "#{SecureRandom.hex(4)}°N #{SecureRandom.hex(4)}°E"
    end

    # Set up initial Craft info
    @craft = Craft::BaseCraft.new(
      name: 'Starship 1',
      craft_name: 'Starship 1',
      craft_type: 'spaceship',
      location: lunar_surface
    )

    @craft.load_craft_info
    @craft.build_units_and_modules

    if @craft.save
      puts "Starship created successfully!"
    else
      puts "Error creating Starship:"
      puts @craft.errors.full_messages
    end
  end

  def build_base_module(module_type)
    case module_type
    when :habitation
      if @resources[:metals] >= 100 && @resources[:water] >= 50
        puts "Habitation module built!"
        @resources[:metals] -= 100
        @resources[:water] -= 50
        @base[:modules] << :habitation
      else
        puts "Not enough resources for habitation module."
      end
    when :power_supply
      if @resources[:metals] >= 50
        puts "Power supply module built!"
        @resources[:metals] -= 50
        @base[:power] += 100
        @base[:modules] << :power_supply
      else
        puts "Not enough resources for power supply module."
      end
    else
      puts "Invalid module type."
    end
  end

  def simulate_month
    puts "Simulating month #{@current_month + 1}..."

    # Resource consumption and updates (simplified)
    @resources[:food] -= @crew * 2  # 2 units of food per crew member per month
    @resources[:water] -= @crew * 1  # 1 unit of water per crew member per month
    @resources[:oxygen] -= @crew * 1  # 1 unit of oxygen per crew member per month
    @resources[:power] -= @crew * 10  # Power consumption for life support

    # Check if we need more resources or modules
    check_survival_necessities

    # Track resource gathering
    gather_resources

    @current_month += 1
  end

  def check_survival_necessities
    # Check if crew's survival needs are met
    if @resources[:food] < 0
      puts "Warning: Not enough food to sustain the crew!"
      return
    end
    if @resources[:water] < 0
      puts "Warning: Not enough water to sustain the crew!"
      return
    end
    if @resources[:oxygen] < 0
      puts "Warning: Not enough oxygen to sustain the crew!"
      return
    end
    if @resources[:power] < 0
      puts "Warning: Power supply is insufficient!"
      return
    end

    # Ensure there is enough habitat space
    required_habitats = (@crew / 4).ceil  # Assume 1 habitat unit can support up to 4 crew members
    current_habitats = @base[:modules].count { |module| module == :habitation }

    if required_habitats > current_habitats
      puts "Not enough habitation units! Building #{required_habitats - current_habitats} more units."
      (required_habitats - current_habitats).times { build_base_module(:habitation) }
    end
  end

  def gather_resources
    # Simulate resource gathering (basic extraction)
    puts "Gathering resources..."
    @resources[:metals] += 20  # Mining lunar regolith
    @resources[:water] += 5    # Extracting water from ice deposits
    @resources[:food] += 10    # Growing food in greenhouse
    @resources[:oxygen] += 5   # Oxygen generator processing

    # Generate power (solar panel simulation)
    @resources[:power] += 20  # Solar panels or other power sources
  end

  def run_simulation
    # Run the first 6 months of the lunar base setup
    while @current_month < 6
      simulate_month
    end
  end
end

# Example usage
simulation = LunarBaseSimulation.new
simulation.create_craft
simulation.build_base_module(:habitation) # Build initial habitation unit
simulation.build_base_module(:power_supply) # Build initial power supply unit
simulation.run_simulation
