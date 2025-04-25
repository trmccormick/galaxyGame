FactoryBot.define do
    factory :geosphere, class: 'CelestialBodies::Spheres::Geosphere' do
      association :celestial_body
      
      temperature { 300 }
      pressure { 1.0 }
      geological_activity { 60 }
      tectonic_activity { true }
      
      # Important: Ensure we're using symbols as strings in the hash
      # This matches the expected format in the material loading code
      crust_composition { { 'Silicon' => 45.0, 'Oxygen' => 30.0, 'Aluminum' => 15.0, 'volatiles' => { 'CO2' => 5.0, 'H2O' => 5.0 } } }
      mantle_composition { { 'Silicon' => 40.0, 'Oxygen' => 40.0, 'Iron' => 15.0, 'Magnesium' => 5.0 } }
      core_composition { { 'Iron' => 85.0, 'Nickel' => 15.0 } }
      
      # ESSENTIAL: Set these to EXACT values - must be precisely equal to the values used in tests
      total_crust_mass { 1000.0 }
      total_mantle_mass { 1.0e22 }
      total_core_mass { 1.0e22 }
      
      skip_simulation { true } # Don't trigger simulation during tests
    end
end
