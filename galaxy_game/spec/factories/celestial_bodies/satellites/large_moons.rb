FactoryBot.define do
  factory :large_moon, class: 'CelestialBodies::Satellites::LargeMoon' do
    sequence(:name) { |n| "Large Moon-#{n}" }
    sequence(:identifier) { |n| "LMOON-#{n}" }
    size { 0.27 }
    gravity { 1.62 }
    density { 3.344 }
    radius { 1.737e6 }
    orbital_period { 27.322 }
    mass { 7.342e22 }
    surface_temperature { 250 }
    albedo { 0.12 }
    known_pressure { 0 }
    association :solar_system
    properties { {} }
    
    trait :luna do
      name { "Luna" }
      # FIX: Use sequence to avoid identifier collision
      sequence(:identifier) { |n| "LUNA-#{n.to_s.rjust(2, '0')}" }
      size { 0.273 }
      gravity { 1.62 }
      density { 3.344 }
      mass { 7.342e22 }
      radius { 1.737e6 }
      orbital_period { 27.322 }
      albedo { 0.12 }
      insolation { 1361 }
      surface_temperature { 250 }
      known_pressure { 0.0 }
      
      # Luna-specific properties
      properties { { 
        "surface_features" => ["craters", "maria", "highlands"],
        "volatiles" => { "H2O" => 0.1, "He3" => 0.001 },
        "minerals" => { "Anorthite" => 60.0, "Ilmenite" => 5.0, "KREEP" => 1.0 }
      } }

      # Luna needs Earth as parent_body (will be set in test setup)
      parent_body { nil } # Set this in the test: parent_body: earth
      
      after(:create) do |luna|
        # Create atmosphere with proper lunar values
        unless luna.atmosphere
          luna.create_atmosphere(
            composition: {},
            pressure: 0.0,
            temperature: luna.surface_temperature,
            total_atmospheric_mass: 0.0,
            pollution: 0,
            dust: { 'concentration' => 0.3, 'particle_size' => 0.002 },
            temperature_data: {
              'tropical_temperature' => luna.surface_temperature,
              'polar_temperature' => luna.surface_temperature - 40
            }
          )
        end
        
        # Create geosphere with lunar properties
        unless luna.geosphere
          luna.create_geosphere(
            temperature: luna.surface_temperature,
            pressure: 0.0,
            geological_activity: 5,
            tectonic_activity: false,
            crust_composition: { 'Silicon' => 45.0, 'Oxygen' => 35.0, 'Aluminum' => 10.0, 'Titanium' => 5.0 },
            core_composition: { 'Iron' => 80.0, 'Nickel' => 20.0 },
            stored_volatiles: { 'H2O' => { 'polar_caps' => 1.0e12 } },
            skip_simulation: true
          )
        end
        
        # Create hydrosphere with lunar properties (minimal water)
        unless luna.hydrosphere
          luna.build_hydrosphere(
            water_bodies: { 'ice_caps' => 1.0e12 },
            state_distribution: { 'solid' => 100.0 },
            temperature: luna.surface_temperature
          ).save!
        end
        
        # Create biosphere (no life on Luna)
        unless luna.biosphere
          luna.create_biosphere(
            biodiversity_index: 0.0,
            habitable_ratio: 0.0
          )
        end

        # Create spatial location
        unless luna.spatial_location
          luna.create_spatial_location(
            x_coordinate: 0.0,
            y_coordinate: 0.0,
            z_coordinate: 0.0
          )
        end
      end
    end
  end
end