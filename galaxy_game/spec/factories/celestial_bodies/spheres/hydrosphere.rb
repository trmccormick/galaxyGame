FactoryBot.define do
  factory :hydrosphere, class: 'CelestialBodies::Spheres::Hydrosphere' do
    association :celestial_body
    temperature { 300 }
    pressure { 1.0 }
    
    # JSONB field values
    liquid_bodies { { 'oceans' => 0.0, 'lakes' => 0.0, 'rivers' => 0.0, 'ice_caps' => 0.0, 'groundwater' => 0.0 } }
    composition { { 'H2O' => 100.0 } }
    state_distribution { { 'liquid' => 0.0, 'solid' => 0.0, 'vapor' => 0.0 } }
    total_liquid_mass { 0.0 }

    # Add a trait for earth-like hydrosphere
    trait :earth do
      liquid_bodies { { 'oceans' => 1.0, 'lakes' => 0.5, 'rivers' => 0.2, 'ice_caps' => 0.1, 'groundwater' => 0.2 } }
      total_liquid_mass { 1.386e21 }
      state_distribution { { 'liquid' => 95.0, 'solid' => 5.0, 'vapor' => 0.0 } }
    end

    # Add a trait for mars-like hydrosphere
    trait :mars do
      liquid_bodies { { 'oceans' => 0.0, 'lakes' => 0.0, 'rivers' => 0.0, 'ice_caps' => 0.5, 'groundwater' => 0.5 } }
      total_liquid_mass { 1.0e18 }
      state_distribution { { 'solid' => 99.0, 'liquid' => 1.0, 'vapor' => 0.0 } }
    end
  end
end
