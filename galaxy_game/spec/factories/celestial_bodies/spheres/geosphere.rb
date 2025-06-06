FactoryBot.define do
  factory :geosphere, class: 'CelestialBodies::Spheres::Geosphere' do
    association :celestial_body
    
    temperature { 300 }
    pressure { 1.0 }
    geological_activity { 60 }
    tectonic_activity { true }
    
    # Add regolith properties
    regolith_depth { 0.0 }
    regolith_particle_size { 0.5 }
    weathering_rate { 1.0 }
    
    # Important: Ensure we're using symbols as strings in the hash
    crust_composition { { 'Silicon' => 45.0, 'Oxygen' => 30.0, 'Aluminum' => 15.0, 'volatiles' => { 'CO2' => 5.0, 'H2O' => 5.0 } } }
    mantle_composition { { 'Silicon' => 40.0, 'Oxygen' => 40.0, 'Iron' => 15.0, 'Magnesium' => 5.0 } }
    core_composition { { 'Iron' => 85.0, 'Nickel' => 15.0 } }
    
    total_crust_mass { 1000.0 }
    total_mantle_mass { 1.0e22 }
    total_core_mass { 1.0e22 }
    
    skip_simulation { true } # Don't trigger simulation during tests
    
    # Add planet-specific traits for consistency
    trait :earth do
      geological_activity { 60 }
      tectonic_activity { true }
      regolith_depth { 5.0 }
      regolith_particle_size { 0.3 }
      weathering_rate { 3.5 }
    end
    
    trait :mars do
      geological_activity { 20 }
      tectonic_activity { false }
      regolith_depth { 10.0 } # Mars has deep regolith but no soil
      regolith_particle_size { 0.1 }
      weathering_rate { 0.2 } # Low due to limited atmosphere
    end
    
    trait :moon do
      geological_activity { 5 }
      tectonic_activity { false }
      regolith_depth { 15.0 } # Lunar regolith can be quite deep
      regolith_particle_size { 0.05 }
      weathering_rate { 0.01 } # Very low due to no atmosphere
    end
  end
end
