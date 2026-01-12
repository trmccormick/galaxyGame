require_relative '../../config/environment'

class SettlementFinder
  IDEAL_TEMPERATURE_RANGE = (273..323).freeze # Kelvin
  IDEAL_GRAVITY_RANGE = (0.8..1.2).freeze # g (9.81 m/s²)
  BREATHABLE_ATMOSPHERE = { 'Oxygen' => 21 }.freeze

  def initialize(system_name:, star_count: 1, planet_count: 5)
    @system = SolarSystem.create!(identifier: generate_identifier, name: system_name)
    StarSim::SystemGeneratorService.new(@system).generate!(
      num_stars: star_count,
      num_planets: planet_count
    )
  end

  def find_best_planet
    best_planet = nil
    best_score = -Float::INFINITY

    planets = CelestialBodies::CelestialBody.where(solar_system_id: @system.id)
    planets.each do |planet|
      score = evaluate_planet(planet)
      if score > best_score
        best_score = score
        best_planet = planet
      end
    end

    best_planet
  end

  private

  def evaluate_planet(planet)
    score = 0

    # Evaluate surface temperature
    if IDEAL_TEMPERATURE_RANGE.cover?(planet.surface_temperature)
      score += 10
    else
      score -= (planet.surface_temperature - IDEAL_TEMPERATURE_RANGE.min).abs
    end

    # Evaluate gravity
    gravity_in_g = planet.gravity / 9.81
    if IDEAL_GRAVITY_RANGE.cover?(gravity_in_g)
      score += 10
    else
      score -= (gravity_in_g - IDEAL_GRAVITY_RANGE.min).abs
    end

    # Evaluate atmosphere composition
    if planet.atmosphere&.composition&.include?('Oxygen')
      score += 10 if planet.atmosphere.composition['Oxygen'] == BREATHABLE_ATMOSPHERE['Oxygen']
    else
      score -= 10
    end

    score
  end

  def generate_identifier
    [*('A'..'Z')].sample(rand(2..4)).join + '-' + rand(100..999999).to_s
  end
end

def random_system_name
  [*('A'..'Z')].sample(rand(2..4)).join + '-' + rand(100..999999).to_s
end

finder = SettlementFinder.new(system_name: random_system_name, star_count: 1, planet_count: 5)

best_planet = finder.find_best_planet

existing_system = SolarSystem.find_by(name: random_system_name)
if existing_system
  puts "Solar system #{random_system_name} already exists."
else
  finder = SettlementFinder.new(system_name: random_system_name, star_count: 1, planet_count: 5)
  best_planet = finder.find_best_planet

  if best_planet
    puts "Best planet for settlement: #{best_planet.name}"
    puts "Surface Temperature: #{best_planet.surface_temperature} K"
    puts "Gravity: #{best_planet.gravity} m/s²"
    puts "Surface Pressure: #{best_planet.atmosphere.pressure} atm"
    puts "Atmosphere Composition: #{best_planet.atmosphere&.composition}"
  else
    puts "No suitable planet found for settlement."
  end
end