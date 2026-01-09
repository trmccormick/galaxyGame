module LifeSupport
  extend ActiveSupport::Concern
  include GameConstants

  included do
    validates :current_population, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  end

  def calculate_life_support_requirements
    return {} if current_population.nil? || current_population.zero?

    {
      food: calculate_food_requirements,
      water: calculate_water_requirements,
      energy: calculate_energy_requirements,
      waste_processing: calculate_waste_requirements
    }
  end

  def check_resource_availability
    resources = calculate_life_support_requirements

    if current_food < (resources[:food] * STARVATION_THRESHOLD)
      handle_starvation
    end
    
    # Separate resource shortage checks to ensure all run
    handle_resource_shortage(:food) if current_food < resources[:food]
    handle_resource_shortage(:water) if current_water < resources[:water]
    handle_resource_shortage(:energy) if current_energy < resources[:energy]
  end

  private

  def handle_starvation
    deaths = (current_population * DEATH_RATE).to_i
    self.current_population -= deaths
    save
  end

  def handle_resource_shortage(resource)
    # Resource shortage handling logic
  end

  def calculate_food_requirements
    current_population * FOOD_PER_PERSON
  end

  def calculate_water_requirements
    current_population * WATER_PER_PERSON
  end

  def calculate_energy_requirements
    current_population * ENERGY_PER_PERSON
  end

  def calculate_waste_requirements
    # Approximate waste processing capacity needed per person per day
    (current_population * WATER_PER_PERSON * 0.6).to_i # Assuming 60% of water becomes waste
  end
end