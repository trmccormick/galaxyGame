FactoryBot.define do
  factory :biosphere, class: 'CelestialBodies::Spheres::Biosphere' do
    association :celestial_body
    temperature_tropical { 300.0 }
    temperature_polar { 250.0 }
    biodiversity_index { 0.0 }
    habitable_ratio { 0.0 }
    biome_distribution { {} }

    # Add a trait for earth-like biosphere
    trait :earth do
      temperature_tropical { 303.15 } # 30°C
      temperature_polar { 258.15 } # -15°C
      biodiversity_index { 0.85 }
      habitable_ratio { 0.7 }
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
      temperature_tropical { 268.15 } # -5°C
      temperature_polar { 208.15 } # -65°C
      biodiversity_index { 0.0 }
      habitable_ratio { 0.0 }
      biome_distribution { {} }
    end
  end
end