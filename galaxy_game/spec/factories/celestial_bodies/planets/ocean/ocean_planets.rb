FactoryBot.define do
  # Base ocean planet factory
  factory :ocean_planet, class: 'CelestialBodies::Planets::Ocean::OceanPlanet' do
    sequence(:name) { |n| "OceanWorld-#{n}" }
    sequence(:identifier) { |n| "OCNP-#{n}" }
    mass { 4.5e24 }
    radius { 6.0e6 }
    size { 0.94 }
    gravity { 9.1 }
    density { 5.2 }
    orbital_period { 310.5 }
    albedo { 0.45 }
    insolation { 1250 }
    surface_temperature { 290 }
    known_pressure { 1.2 }
    properties { {} }

    before(:build) do |planet|
      planet.properties ||= {}
    end

    after(:build) do |planet|
      planet.surface_area ||= 4 * Math::PI * (planet.radius ** 2) if planet.radius
      planet.properties = planet.properties.merge({
        "habitability_index" => 0.8,
        "surface_features" => ["oceans", "island_chains", "coastal_regions"]
      })
      
      unless planet.hydrosphere
        total_water_area = planet.surface_area * 0.45
        planet.hydrosphere = build(:hydrosphere,
          celestial_body: planet,
          liquid_bodies: {
            'oceans' => total_water_area * 0.7,
            'lakes' => total_water_area * 0.2,
            'rivers' => total_water_area * 0.1,
            'ice_caps' => 0,
            'groundwater' => 0
          },
          composition: { 'water' => 97, 'salts' => 3 },
          temperature: planet.surface_temperature,
          pressure: 101325,
          state_distribution: { 'liquid' => 95, 'vapor' => 3, 'solid' => 2 },
          total_hydrosphere_mass: 4.5e20
        )
      end
    end

    after(:create) do |planet|
      unless planet.atmosphere
        atmo = planet.create_atmosphere(
          pressure: 1.2,
          temperature: planet.surface_temperature,
          humidity: 65,
          total_atmospheric_mass: 5.2e18
        )
        ['N2', 'O2', 'CO2'].each do |gas_name|
          percentage = case gas_name
                      when 'N2' then 78
                      when 'O2' then 21
                      when 'CO2' then 1
                      end
          atmo.gases.create(name: gas_name, percentage: percentage)
        end
      end
      
      unless planet.geosphere
        planet.create_geosphere(
          geological_activity: 40,
          tectonic_activity: true,
          crust_composition: {
            'Silicon' => 45.0, 
            'Oxygen' => 30.0, 
            'Magnesium' => 10.0,
            'Iron' => 8.0
          }
        )
      end
      
      unless planet.biosphere
        planet.create_biosphere(
          biodiversity_index: 0.6,
          habitable_ratio: 0.4
        )
      end
      
      unless planet.spatial_location
        planet.create_spatial_location(
          x_coordinate: rand(-100.0..100.0),
          y_coordinate: rand(-100.0..100.0),
          z_coordinate: rand(-100.0..100.0)
        )
      end
    end
  end

  factory :water_world, class: 'CelestialBodies::Planets::Ocean::WaterWorld' do
    sequence(:name) { |n| "Oceanus-#{n}" }
    sequence(:identifier) { |n| "WATR-#{n}" }
    mass { 5.5e24 }
    radius { 6.4e6 }
    size { 1.01 }
    gravity { 8.8 }
    density { 4.9 }
    orbital_period { 295 }
    albedo { 0.67 }
    insolation { 1320 }
    surface_temperature { 285 }
    known_pressure { 1.0 }
    properties { {} }
    
    before(:build) do |planet|
      planet.properties ||= {}
    end
    
    after(:build) do |planet|
      planet.surface_area ||= 4 * Math::PI * (planet.radius ** 2) if planet.radius
      planet.properties = planet.properties.merge({
        "habitability_index" => 0.75,
        "surface_features" => ["global_ocean", "scattered_islands", "underwater_mountains"]
      })
    end
    
    after(:create) do |planet|
      if planet.surface_area.present?
        total_water_area = planet.surface_area * 0.90
        
        unless planet.hydrosphere
          planet.create_hydrosphere(
            celestial_body: planet,
            liquid_bodies: {
              'oceans' => total_water_area * 0.95,
              'lakes' => total_water_area * 0.03,
              'rivers' => total_water_area * 0.02,
              'ice_caps' => 0,
              'groundwater' => 0
            },
            composition: { 'water' => 95, 'salts' => 5 },
            temperature: planet.surface_temperature,
            pressure: 101325,
            state_distribution: { 'liquid' => 98, 'vapor' => 1, 'solid' => 1 },
            total_hydrosphere_mass: 9.0e21
          )
        end
      end
      
      unless planet.atmosphere
        atmo = planet.create_atmosphere(
          pressure: 1.0,
          temperature: planet.surface_temperature,
          humidity: 78,
          total_atmospheric_mass: 5.0e18
        )
        
        ['N2', 'O2', 'Ar'].each do |gas_name|
          percentage = case gas_name
                      when 'N2' then 78
                      when 'O2' then 21
                      when 'Ar' then 1
                      end
          
          atmo.gases.create(name: gas_name, percentage: percentage)
        end
      end
      
      unless planet.geosphere
        planet.create_geosphere(
          geological_activity: 45,
          tectonic_activity: true,
          crust_composition: {
            'Silicon' => 42.0, 
            'Oxygen' => 28.0, 
            'Magnesium' => 15.0,
            'Iron' => 10.0
          }
        )
      end
      
      unless planet.biosphere
        planet.create_biosphere(
          biodiversity_index: 0.85,
          habitable_ratio: 0.7
        )
      end
      
      unless planet.spatial_location
        planet.create_spatial_location(
          x_coordinate: rand(-100.0..100.0),
          y_coordinate: rand(-100.0..100.0),
          z_coordinate: rand(-100.0..100.0)
        )
      end
    end
    
    trait :ice_capped do
      surface_temperature { 275 }
      
      after(:create) do |planet|
        if planet.hydrosphere && planet.surface_area.present?
          ice_area = planet.surface_area * 0.20
          planet.hydrosphere.update(
            liquid_bodies: planet.hydrosphere.liquid_bodies.merge({
              'ice_caps' => ice_area
            }),
            state_distribution: { 'liquid' => 78, 'solid' => 20, 'vapor' => 2 }
          )
        end
      end
    end
    
    trait :warm do
      surface_temperature { 305 }
      
      after(:create) do |planet|
        if planet.atmosphere
          planet.atmosphere.update(humidity: 85)
        end
        
        if planet.hydrosphere
          planet.hydrosphere.update(
            state_distribution: { 'liquid' => 92, 'vapor' => 8, 'solid' => 0 }
          )
        end
      end
    end
    
    trait :with_solar_system do
      after(:build) do |planet|
        planet.solar_system ||= build(:solar_system)
      end
      
      after(:create) do |planet|
        if planet.solar_system&.current_star && planet.star_distances.empty?
          planet.star_distances.create!(
            star: planet.solar_system.current_star,
            distance: 1.05
          )
        end
      end
    end
  end
  
  # Pelagic planet - a specialized water world with global and very deep ocean
  factory :pelagic_planet, class: 'CelestialBodies::Planets::Ocean::WaterWorld' do
    sequence(:name) { |n| "Pelagos-#{n}" }
    sequence(:identifier) { |n| "PLGC-#{n}" }
    mass { 6.2e24 } # Slightly more than Earth
    radius { 7.0e6 } # Larger than Earth
    size { 1.10 }
    gravity { 8.4 }
    density { 4.6 }
    orbital_period { 380 }
    albedo { 0.72 } # Very high albedo due to almost complete water coverage
    insolation { 1150 }
    surface_temperature { 288 } # About 15°C average
    known_pressure { 2.5 }
    properties { {} }
    
    # Calculate surface area from radius
    after(:build) do |planet|
      planet.surface_area ||= 4 * Math::PI * (planet.radius ** 2) if planet.radius
    end
    
    before(:build) do |planet|
      planet.properties ||= {}
      planet.properties = planet.properties.merge({
        "habitability_index" => 0.9, # High habitability for aquatic life
        "surface_features" => ["global_ocean", "no_exposed_land", "deep_trenches", "underwater_mountains"]
      })
    end
    
    after(:create) do |planet|
      # Calculate water areas to achieve 98% coverage
      if planet.surface_area.present?
        total_water_area = planet.surface_area * 0.98
        
        # Create nearly 100% water coverage and very deep hydrosphere
        unless planet.hydrosphere
          planet.create_hydrosphere(
            celestial_body: planet,
            liquid_bodies: {
              'oceans' => total_water_area * 0.99,   # Almost everything is ocean
              'lakes' => 0,
              'rivers' => 0,
              'ice_caps' => 0,
              'groundwater' => total_water_area * 0.01
            },
            composition: { 'water' => 96, 'salts' => 4 },
            temperature: planet.surface_temperature,
            pressure: 250000, # 2.5 atm
            state_distribution: { 'liquid' => 99, 'vapor' => 1 },
            total_hydrosphere_mass: 2.8e22
          )
        end
      end
      
      # Create dense atmosphere
      unless planet.atmosphere
        atmo = planet.create_atmosphere(
          pressure: 2.5,
          humidity: 95,
          temperature: planet.surface_temperature,
          total_atmospheric_mass: 1.3e19
        )
        
        # Add appropriate gases
        ['N2', 'O2', 'H2O', 'CO2'].each do |gas_name|
          percentage = case gas_name
                      when 'N2' then 75
                      when 'O2' then 18
                      when 'H2O' then 5 # High water vapor content
                      when 'CO2' then 2
                      end
          
          atmo.gases.create(name: gas_name, percentage: percentage)
        end
      end
      
      # Create geosphere
      unless planet.geosphere
        planet.create_geosphere(
          geological_activity: 70, # High activity under the ocean
          tectonic_activity: true,
          crust_composition: {
            'Silicon' => 44.0, 
            'Oxygen' => 30.0, 
            'Magnesium' => 12.0,
            'Iron' => 8.0,
            'Calcium' => 6.0
          }
        )
      end
      
      # Create rich biosphere for underwater life
      unless planet.biosphere
        planet.create_biosphere(
          biodiversity_index: 0.95,
          biomass: 3.5e14,
          habitable_ratio: 0.9
        )
      end
      
      # Create spatial location
      unless planet.spatial_location
        planet.create_spatial_location(
          x_coordinate: rand(-100.0..100.0),
          y_coordinate: rand(-100.0..100.0),
          z_coordinate: rand(-100.0..100.0)
        )
      end
    end
    
    trait :with_solar_system do
      after(:build) do |planet|
        planet.solar_system ||= build(:solar_system)
      end
      
      after(:create) do |planet|
        if planet.solar_system&.current_star && planet.star_distances.empty?
          planet.star_distances.create!(
            star: planet.solar_system.current_star,
            distance: 1.1
          )
        end
      end
    end
  end
end