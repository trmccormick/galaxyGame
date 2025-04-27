FactoryBot.define do
  factory :celestial_body, class: 'CelestialBodies::CelestialBody' do
    sequence(:name) { |n| "CelestialBody#{n}" }
    size { 1.0 }
    gravity { 9.807 }
    density { 5.514 }
    mass { 5.972e24 }
    radius { 6_371_000.0 }
    status { "active" }
    orbital_period { 365.25 }
    albedo { 0.306 }
    insolation { 1361 }
    surface_temperature { 15 }
    known_pressure { 1.0 }
    sequence(:identifier) { |n| "Celestial Body #{n}" }
    association :solar_system

    after(:create) do |celestial_body|
      create(:spatial_location, spatial_context: celestial_body)

      # Create associations with the correct approach
      celestial_body.create_atmosphere unless celestial_body.atmosphere
      celestial_body.create_biosphere unless celestial_body.biosphere
      celestial_body.create_hydrosphere unless celestial_body.hydrosphere
      celestial_body.create_geosphere unless celestial_body.geosphere

      # Assign proper attributes to geosphere
      if celestial_body.geosphere
        celestial_body.geosphere.assign_attributes(
          temperature: celestial_body.surface_temperature,
          pressure: celestial_body.atmosphere.pressure || 1.0,
          geological_activity: 50,
          tectonic_activity: true,
          crust_composition: { 'Silicon' => 45.0, 'Oxygen' => 30.0, 'Aluminum' => 15.0, 'volatiles' => { 'CO2' => 5.0, 'H2O' => 5.0 } },
          mantle_composition: { 'Silicon' => 40.0, 'Oxygen' => 40.0, 'Iron' => 15.0, 'Magnesium' => 5.0 },
          core_composition: { 'Iron' => 85.0, 'Nickel' => 15.0 },
          total_crust_mass: 1.0e20,
          total_mantle_mass: 1.0e22,
          total_core_mass: 1.0e22
        )
        celestial_body.geosphere.skip_simulation = true
        celestial_body.geosphere.save!
      end

      celestial_body.atmosphere.assign_attributes(
        temperature: celestial_body.surface_temperature,
        pressure: 0,
        composition: {},
        total_atmospheric_mass: 0,
        pollution: 0,
        dust: {}
      )

      celestial_body.biosphere.assign_attributes(
        temperature_tropical: 0,
        temperature_polar: 0
      )

      celestial_body.hydrosphere.assign_attributes(
        temperature: celestial_body.surface_temperature,
        pressure: celestial_body.known_pressure,
        water_bodies: { 
          'oceans' => 0, 
          'lakes' => 0, 
          'rivers' => 0, 
          'ice_caps' => 0, 
          'groundwater' => 0 
        },
        composition: { 'H2O' => 100.0 },
        state_distribution: { 'liquid' => 0.0, 'solid' => 0.0, 'vapor' => 0.0 },
        total_water_mass: 0.0
      )

      celestial_body.atmosphere.save if celestial_body.atmosphere.new_record?
      celestial_body.biosphere.save if celestial_body.biosphere.new_record?
      celestial_body.geosphere.save if celestial_body.geosphere.new_record?
      celestial_body.hydrosphere.save if celestial_body.hydrosphere.new_record?
    end

    after(:create) do |body|
      # Create geosphere after the body is fully created and saved
      create(:geosphere, celestial_body: body) unless body.geosphere
    end

    trait :earth do
      name { "Earth" }
      size { 1.0 }
      gravity { 9.807 }
      density { 5.514 }
      mass { 5.972e24 }
      radius { 6_371_000.0 }
      orbital_period { 365.25 }
      albedo { 0.306 }
      insolation { 1361 }
      surface_temperature { 15 }
      known_pressure { 1.0 }

      after(:create) do |celestial_body|
        # Initialize associations
        # celestial_body.initialize_associations

        celestial_body.star_distances.create(distance: 1.0)
  
        celestial_body.atmosphere.assign_attributes(
          composition: { 'N2' => 0.78, 'O2' => 0.21, 'CO2' => 0.0004 },
          pressure: 1.0,
          total_atmospheric_mass: 5.148e18,
          pollution: 0,
          dust: {}
        )
  
        celestial_body.biosphere.assign_attributes(
          temperature_tropical: 300,
          temperature_polar: 260
        )
  
        # celestial_body.geosphere.assign_attributes(
        #   rock_types: { 'granite' => 0.5, 'basalt' => 0.4 },
        #   geological_activity: 1
        # )
  
        celestial_body.hydrosphere.assign_attributes(
          liquid_name: 'water',
          liquid_volume: 1.386e21,
          lakes: 20,
          rivers: 100,
          oceans: 1,
          ice: 5
        )

        celestial_body.geosphere.assign_attributes(
          temperature: celestial_body.surface_temperature,
          pressure: celestial_body.atmosphere.pressure || 1.0,
          geological_activity: 50,
          tectonic_activity: true,
          crust_composition: { 'Silicon' => 45.0, 'Oxygen' => 30.0, 'Aluminum' => 15.0, 'volatiles' => { 'CO2' => 5.0, 'H2O' => 5.0 } },
          mantle_composition: { 'Silicon' => 40.0, 'Oxygen' => 40.0, 'Iron' => 15.0, 'Magnesium' => 5.0 },
          core_composition: { 'Iron' => 85.0, 'Nickel' => 15.0 },
          total_crust_mass: 1.0e20,
          total_mantle_mass: 1.0e22,
          total_core_mass: 1.0e22
        )
        celestial_body.geosphere.skip_simulation = true
  
        # Save associations after assigning attributes
        celestial_body.atmosphere.save if celestial_body.atmosphere.new_record?
        celestial_body.biosphere.save if celestial_body.biosphere.new_record?
        celestial_body.geosphere.save if celestial_body.geosphere.new_record?
        celestial_body.hydrosphere.save if celestial_body.hydrosphere.new_record?
      end      
    end

    trait :mars do
      name { "Mars" }
      size { 0.53 }
      gravity { 3.71 }
      density { 3.93 }
      mass { 6.4171e23 }
      radius { 3_390_000.0 }
      orbital_period { 687.0 }
      albedo { 0.25 }
      insolation { 590 }
      surface_temperature { -60 }
      known_pressure { 0.006 }

      after(:create) do |celestial_body|
        celestial_body.star_distances.create(distance: 1.52)
        celestial_body.atmosphere.assign_attributes(
          composition: { 'CO2' => 0.95, 'N2' => 0.027, 'Ar' => 0.016 },
          pressure: 0.006,
          total_atmospheric_mass: 2.5e16,
          pollution: 0,
          dust: {}
        )
  
        celestial_body.biosphere.assign_attributes(
          temperature_tropical: -20,
          temperature_polar: -125
        )
  
        # celestial_body.geosphere.assign_attributes(
        #   rock_types: { 'basalt' => 0.7, 'andesite' => 0.3 },
        #   geological_activity: 0.1
        # )
  
        celestial_body.hydrosphere.assign_attributes(
          liquid_volume: 0,
          lakes: 0,
          rivers: 0,
          oceans: 0,
          ice: 5
        )

        celestial_body.geosphere.assign_attributes(
          temperature: celestial_body.surface_temperature,
          pressure: celestial_body.atmosphere.pressure || 1.0,
          geological_activity: 50,
          tectonic_activity: true,
          crust_composition: { 'Silicon' => 45.0, 'Oxygen' => 30.0, 'Aluminum' => 15.0, 'volatiles' => { 'CO2' => 5.0, 'H2O' => 5.0 } },
          mantle_composition: { 'Silicon' => 40.0, 'Oxygen' => 40.0, 'Iron' => 15.0, 'Magnesium' => 5.0 },
          core_composition: { 'Iron' => 85.0, 'Nickel' => 15.0 },
          total_crust_mass: 1.0e20,
          total_mantle_mass: 1.0e22,
          total_core_mass: 1.0e22
        )
        celestial_body.geosphere.skip_simulation = true
  
        # Save associations after assigning attributes
        celestial_body.atmosphere.save if celestial_body.atmosphere.new_record?
        celestial_body.biosphere.save if celestial_body.biosphere.new_record?
        celestial_body.geosphere.save if celestial_body.geosphere.new_record?
        celestial_body.hydrosphere.save if celestial_body.hydrosphere.new_record?
      end      
    end

    trait :venus do
      name { "Venus" }
      size { 0.95 }
      gravity { 8.87 }
      density { 5.24 }
      mass { 4.867e24 }
      radius { 6_052_000.0 }
      orbital_period { 225.0 }
      albedo { 0.77 }
      insolation { 2613.9 }
      surface_temperature { 464 }
      known_pressure { 92 }

      after(:create) do |celestial_body|
        celestial_body.star_distances.create(distance: 0.72)
        celestial_body.atmosphere.assign_attributes(
          composition: { 'CO2' => 0.965, 'N2' => 0.035 },
          pressure: 92,
          total_atmospheric_mass: 4.8e20,
          pollution: 0,
          dust: {}
        )
        celestial_body.atmosphere.save if celestial_body.atmosphere.new_record?
      end
    end

    trait :luna do
      name { "Luna" }
      identifier { "LUNA-01" }
      mass { '7.342e22' }
      radius { 1.737e6 }
      density { 3.344 }
      size { 0.2727 }
      orbital_period { 27.322 }
      surface_temperature { 250 }
      gravity { 1.62 }
      albedo { 0.12 }
      geological_activity { 5 }
      
      after(:create) do |celestial_body|
        celestial_body.star_distances.create(distance: 1.496e8)
        
        celestial_body.atmosphere.assign_attributes(
          composition: {},
          dust: { concentration: 0, properties: "Negligible atmosphere" },
          pressure: 0,
          total_atmospheric_mass: 0
        )
    
        celestial_body.create_geosphere!(
          geological_activity: 5,
          tectonic_activity: false,
          crust_composition: {
            oxides: {
              "SiO2" => 43.0,
              "Al2O3" => 24.0,
              "FeO" => 13.0,
              "CaO" => 11.0,
              "MgO" => 7.0,
              "TiO2" => 2.0
            },
            volatiles: {
              "H2O" => 0.1,
              "He3" => 0.001
            },
            minerals: {
              "Anorthite" => 60.0,
              "Ilmenite" => 5.0,
              "KREEP" => 1.0
            }
          }
        )
    
        celestial_body.hydrosphere.assign_attributes(
          temperature: 250,
          pressure: 0,
          water_bodies: { 
            'ice_caps' => 1.0, 
            'groundwater' => 0.0,
          },
          composition: { 'H2O' => 99.0, 'minerals' => 1.0 },
          state_distribution: { 'solid' => 100.0, 'liquid' => 0.0, 'vapor' => 0.0 },
          total_water_mass: 1.0e15  # Small amount of water ice
        )
    
        celestial_body.atmosphere.save if celestial_body.atmosphere.new_record?
        celestial_body.hydrosphere.save if celestial_body.hydrosphere.new_record?
      end      
    end

    trait :with_solar_system do
      after(:create) do |celestial_body|
        create(:solar_system, celestial_body: celestial_body)
      end
    end

    trait :with_surface_locations do
      after(:create) do |celestial_body|
        create_list(:celestial_location, 2, celestial_body: celestial_body)
      end
    end

    trait :terrestrial_planet do
      # Include attributes specific to TerrestrialPlanet, e.g.,
      gravity { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
      density { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
      radius { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
      celestial_type { 'terrestrial_planet' } # If you still use this attribute
    end
    
    trait :gas_giant do
      # Include attributes specific to GasGiant, e.g.,
      hydrogen_concentration { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
      helium_concentration { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
      celestial_type { 'gas_giant' } # If you still use this attribute
    end

    trait :minimal do
      name { "Test Planet #{SecureRandom.hex(4)}" }
      
      after(:create) do |body|
        create(:atmosphere, celestial_body: body) unless body.atmosphere
        create(:hydrosphere, celestial_body: body) unless body.hydrosphere
        create(:geosphere, celestial_body: body) unless body.geosphere
      end
    end    
  end
end