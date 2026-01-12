namespace :generators do
  desc "Test the StarSim generators with a sample star"
  task test: :environment do
    # Create a test star
    star = CelestialBodies::Star.create!(
      name: "Test Star",
      identifier: "TEST-STAR-#{SecureRandom.hex(4)}",
      type_of_star: "G",
      age: 4.6e9,
      mass: 1.989e30,
      radius: 696_340_000.0,
      luminosity: 1.0,
      temperature: 5778,
      life: 10.0e9
    )
    
    puts "Created test star: #{star.name} (ID: #{star.id})"
    
    # Test PlanetarySeedGenerator
    seed_generator = StarSim::PlanetarySeedGenerator.new(star: star, num_planets: 5)
    seeds = seed_generator.generate
    puts "Generated #{seeds.length} planet seeds"
    seeds.each do |seed|
      puts "  Planet #{seed[:index]}: #{seed[:type]} at #{seed[:orbital_distance]} AU"
    end
    
    # Test other generators...
    
    # Clean up
    star.destroy
  end
end