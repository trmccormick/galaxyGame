FactoryBot.define do
  factory :biosphere, class: 'CelestialBodies::Spheres::Biosphere' do
    # Make sure we have a celestial body first
    association :celestial_body
    
    # After creating biosphere, ensure atmosphere exists
    after(:create) do |biosphere|
      # Create atmosphere with temperature data if it doesn't exist
      unless biosphere.celestial_body.atmosphere
        create(:atmosphere, 
               celestial_body: biosphere.celestial_body,
               temperature_data: {
                 'tropical_temperature' => 300.0,
                 'polar_temperature' => 250.0
               })
      end
    end
    
    biodiversity_index { 0.0 }
    habitable_ratio { 0.0 }
    biome_distribution { {} }
    
    # Add soil properties
    soil_health { 0 }
    soil_organic_content { 0.0 }
    soil_microbial_activity { 0.0 }

    # Add a trait for earth-like biosphere
    trait :earth do
      biodiversity_index { 0.85 }
      habitable_ratio { 0.7 }
      
      # Add rich soil properties for Earth
      soil_health { 85 }
      soil_organic_content { 4.5 }
      soil_microbial_activity { 0.8 }
      
      biome_distribution {
        {
          'tropical_rainforest' => { 'area_percentage' => 20.0 },
          'temperate_forest' => { 'area_percentage' => 25.0 },
          'grassland' => { 'area_percentage' => 30.0 },
          'desert' => { 'area_percentage' => 15.0 },
          'tundra' => { 'area_percentage' => 10.0 }
        }
      }
    end

    # Add a trait for mars-like biosphere (barren)
    trait :mars do
      biodiversity_index { 0.0 }
      habitable_ratio { 0.0 }
      soil_health { 0 }
      soil_organic_content { 0.0 }
      soil_microbial_activity { 0.0 }
      biome_distribution { {} }
    end
    
    # For testing biosphere-geosphere interfaces
    trait :with_minimal_soil do
      soil_health { 15 }
      soil_organic_content { 0.8 }
      soil_microbial_activity { 0.1 }
    end
    
    trait :with_rich_soil do
      soil_health { 85 }
      soil_organic_content { 4.5 }
      soil_microbial_activity { 0.8 }
    end

    # Add default values for temperature to prevent nil issues
    trait :with_temperature do
      after(:create) do |biosphere|
        atmosphere = create(:atmosphere, celestial_body: biosphere.celestial_body)
        atmosphere.update(temperature_data: {
          'tropical_temperature' => 310.0,
          'polar_temperature' => 240.0
        })
      end
    end
  end
end