FactoryBot.define do
  # Base factory with all required attributes
  factory :celestial_body, class: 'CelestialBodies::CelestialBody' do
    sequence(:name) { |n| "CelestialBody#{n}" }
    sequence(:identifier) { |n| "CBODY-#{n}" } # Required field
    size { 1.0 }
    gravity { 9.807 }
    density { 5.514 }
    mass { 5.972e24 }
    radius { 6_371_000.0 }
    status { "active" }
    orbital_period { 365.25 }
    albedo { 0.306 }
    insolation { 1361 }
    surface_temperature { 288.0 } # Updated to Kelvin, not Celsius
    known_pressure { 1.0 }
    properties { {} }  # Must initialize as empty hash, NOT null

    # Set solar_system to nil by default, then use traits to add it
    solar_system { nil }

    # Ensure properties is ALWAYS initialized before saving
    before(:build) do |celestial_body|
      celestial_body.properties ||= {}
    end
    
    # After create callback
    after(:create) do |celestial_body|
      # Ensure properties is never nil
      celestial_body.properties ||= {}
      
      # Create required associated objects if they don't exist
      celestial_body.create_atmosphere unless celestial_body.atmosphere
      celestial_body.create_hydrosphere unless celestial_body.hydrosphere
      celestial_body.create_geosphere unless celestial_body.geosphere
      celestial_body.create_biosphere unless celestial_body.biosphere
      
      # Create a spatial location if needed
      unless celestial_body.spatial_location
        # Create the spatial location directly through the association
        location = celestial_body.create_spatial_location(
          x_coordinate: 0.0,
          y_coordinate: 0.0, 
          z_coordinate: 0.0
        )
        
        # Forcefully reload and verify coordinates
        celestial_body.reload
        if celestial_body.spatial_location&.x_coordinate.nil?
          # If coordinates are still nil, try updating them directly
          if celestial_body.spatial_location
            celestial_body.spatial_location.update_columns(
              x_coordinate: 0.0,
              y_coordinate: 0.0,
              z_coordinate: 0.0
            )
            celestial_body.reload
          end
        end
      end
    end

    trait :with_surface_locations do
      after(:create) do |celestial_body|
        create_list(:celestial_location, 2, celestial_body: celestial_body)
      end
    end

    trait :with_solar_system do
      # Create a solar system and associate it properly
      after(:build) do |celestial_body|
        celestial_body.solar_system ||= build(:solar_system)
      end
      
      after(:create) do |celestial_body|
        # Ensure the celestial body has a star distance if it's in a solar system
        if celestial_body.solar_system&.current_star && celestial_body.star_distances.empty?
          celestial_body.star_distances.create!(
            star: celestial_body.solar_system.current_star,
            distance: 1.0
          )
        end
      end
    end    

    trait :minimal do
      name { "Test Planet #{SecureRandom.hex(4)}" }
      
      after(:create) do |body|
        create(:atmosphere, celestial_body: body) unless body.atmosphere
        create(:hydrosphere, celestial_body: body) unless body.hydrosphere
        create(:geosphere, celestial_body: body) unless body.geosphere
      end
    end
    
    trait :luna do
      name { "Luna" }
      identifier { "LUNA-01" }  # Match the identifier in the seed data
      size { 0.273 }
      gravity { 1.62 }
      density { 3.344 }  # Match the precise value
      mass { "7.342e22" }  # Use string format to match seed
      radius { 1.737e6 }
      orbital_period { 27.322 }
      albedo { 0.12 }
      insolation { 1361 }
      surface_temperature { 250 }  # Match the seed temperature
      known_pressure { 0.0 }
      
      # Ensure properties is never null with non-empty value
      properties { { 
        "surface_features" => ["craters", "maria", "highlands"],
        "volatiles" => { "H2O" => 0.1, "He3" => 0.001 },
        "minerals" => { "Anorthite" => 60.0, "Ilmenite" => 5.0, "KREEP" => 1.0 }
      } }
      
      # Associate with a solar system
      association :solar_system

      after(:create) do |celestial_body|
        create(:spatial_location, spatial_context: celestial_body) 
        
        # Create atmosphere with proper lunar values AND temperature data
        unless celestial_body.atmosphere
          celestial_body.create_atmosphere(
            composition: {},
            pressure: 0.0,
            temperature: celestial_body.surface_temperature,
            total_atmospheric_mass: 0.0,
            pollution: 0,
            dust: { 'concentration' => 0.3, 'particle_size' => 0.002 },
            temperature_data: {
              'tropical_temperature' => celestial_body.surface_temperature,
              'polar_temperature' => celestial_body.surface_temperature - 40
            }
          )
        end
        
        # Create geosphere with lunar properties
        celestial_body.geosphere.update_columns(
          crust_composition: { 'regolith' => 100.0, 'Silicon' => 45.0, 'Oxygen' => 35.0, 'Aluminum' => 10.0, 'Titanium' => 5.0 },
          stored_volatiles: { 'H2O' => 1.0e12, 'He3' => 100.0 }
        )
        celestial_body.geosphere.reload
        
        # Create hydrosphere with lunar properties (minimal)
        unless celestial_body.hydrosphere
          celestial_body.create_hydrosphere(
            water_bodies: { 'ice_caps' => 1.0e12 },
            state_distribution: { 'solid' => 100.0 },
            temperature: celestial_body.surface_temperature
          )
        end
        
        # Create biosphere WITHOUT temperature attributes
        unless celestial_body.biosphere
          celestial_body.create_biosphere(
            biodiversity_index: 0.0,
            habitable_ratio: 0.0
          )
        end
        
        # Add star distance
        celestial_body.star_distances.create(distance: 1.0) if celestial_body.star_distances.empty?
      end

      # Override has_solid_surface? for Luna since it's a solid body
      after(:build) do |celestial_body|
        celestial_body.properties ||= {}
        celestial_body.properties = celestial_body.properties.merge(
          "surface_features" => ["craters", "maria", "highlands"]
        )
        # Define singleton method to override has_solid_surface?
        celestial_body.define_singleton_method(:has_solid_surface?) { true }
      end
    end

    # Add trait for when you don't want auto-created spheres
    trait :without_spheres do
      # No callbacks to create spheres
      after(:create) { |body| nil }
    end
  end
end