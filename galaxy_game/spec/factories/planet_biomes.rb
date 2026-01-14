# spec/factories/planet_biomes.rb
FactoryBot.define do
  # Define the factory with both a simple name and an alias for the namespaced version
  factory :planet_biome, class: 'CelestialBodies::PlanetBiome', aliases: [:celestial_bodies_planet_biome] do
    # Associations
    association :biome # Biome is top-level, so no explicit factory name needed here

    # Change this to match the actual factory name from your biosphere.rb factory
    association :biosphere, factory: :biosphere # Use simple name instead of namespaced name

    # Rename water_level to moisture_level for domain correctness
    transient do
      # Use transients for values that might need custom handling
      water_level_value { Faker::Number.between(from: 0.0, to: 1.0).round(2) }
    end

    # Attributes that will be handled by store_accessor on the 'properties' JSONB column
    area_percentage { Faker::Number.between(from: 0.0, to: 100.0).round(2) }
    vegetation_cover { Faker::Number.between(from: 0.0, to: 1.0).round(2) }
    moisture_level { water_level_value } # Rename from water_level to moisture_level
    latitude { Faker::Number.between(from: -90.0, to: 90.0).round(2) }
    optimal_temperature { Faker::Number.between(from: 273.0, to: 310.0).round(2) }
    biodiversity { Faker::Number.between(from: 0.0, to: 1.0).round(2) }
  end
end
  