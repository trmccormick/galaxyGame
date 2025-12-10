FactoryBot.define do
  # Hycean planet - ocean world with hydrogen-rich atmosphere
  factory :hycean_planet, class: 'CelestialBodies::Planets::Ocean::HyceanPlanet' do
    sequence(:name) { |n| "Hydros-#{n}" }
    sequence(:identifier) { |n| "HYCN-#{n}" }
    mass { 8.0e24 }
    radius { 7.5e6 }
    size { 1.18 }
    gravity { 11.2 }
    density { 4.5 }
    orbital_period { 410 }
    albedo { 0.55 }
    insolation { 980 }
    surface_temperature { 350 }
    known_pressure { 15.0 }
    properties { {} }
    
    before(:build) do |planet|
      planet.properties ||= {}
    end
    
    after(:build) do |planet|
      # Calculate surface area from radius
      planet.surface_area ||= 4 * Math::PI * (planet.radius ** 2) if planet.radius
      
      planet.properties = planet.properties.merge({
        "habitability_index" => 0.4,
        "surface_features" => ["global_ocean", "hydrogen_atmosphere", "exotic_cloud_formations"]
      })
      
      # Build hydrosphere BEFORE creation to satisfy validation
      unless planet.hydrosphere
        if planet.surface_area.present?
          total_water_area = planet.surface_area * 0.85
          
          planet.hydrosphere = build(:hydrosphere,
            celestial_body: planet,
            liquid_bodies: {
              'oceans' => total_water_area * 0.98,
              'lakes' => total_water_area * 0.01,
              'rivers' => total_water_area * 0.01,
              'ice_caps' => 0,
              'groundwater' => 0
            },
            composition: { 
              'water' => 88, 
              'ammonia' => 7, 
              'methane' => 3,
              'salts' => 2 
            },
            temperature: planet.surface_temperature,
            pressure: 1500000,
            state_distribution: { 'liquid' => 100 },
            total_hydrosphere_mass: 1.2e22
          )
        end
      end
      
      # Build atmosphere BEFORE creation to satisfy Hycean validation requirements
      unless planet.atmosphere
        planet.atmosphere = build(:atmosphere,
          celestial_body: planet,
          pressure: planet.known_pressure || 15.0,
          temperature: planet.surface_temperature,
          total_atmospheric_mass: 8.5e19
        )
      end
    end
    
    # Override the default create strategy to handle the atmosphere validation
    to_create do |instance|
      # Save without validations first to get the planet persisted
      instance.save(validate: false)
      
      # Ensure atmosphere exists and has the required gases
      if instance.atmosphere
        # Clear any existing gases to avoid duplicates
        instance.atmosphere.gases.destroy_all if instance.atmosphere.persisted?
        
        # Add hydrogen-rich gases that meet Hycean requirements
        # Must have at least 10% hydrogen and significant pressure (>1 atm)
        ['H2', 'He', 'CH4', 'NH3'].each do |gas_name|
          percentage = case gas_name
                      when 'H2' then 60  # Well above 10% requirement
                      when 'He' then 30
                      when 'CH4' then 7
                      when 'NH3' then 3
                      end
          
          instance.atmosphere.gases.create!(name: gas_name, percentage: percentage)
        end
        
        # Ensure pressure meets requirement (>1 atm)
        if instance.atmosphere.pressure < 1.0
          instance.atmosphere.update_column(:pressure, 15.0)
        end
      else
        # Create atmosphere if it somehow doesn't exist
        atmo = instance.create_atmosphere(
          pressure: instance.known_pressure || 15.0,
          temperature: instance.surface_temperature,
          total_atmospheric_mass: 8.5e19
        )
        
        # Add hydrogen-rich gases
        ['H2', 'He', 'CH4', 'NH3'].each do |gas_name|
          percentage = case gas_name
                      when 'H2' then 60
                      when 'He' then 30
                      when 'CH4' then 7
                      when 'NH3' then 3
                      end
          
          atmo.gases.create!(name: gas_name, percentage: percentage)
        end
      end
      
      # Reload to pick up all associations
      instance.reload
      
      # Now validate to ensure everything is correct
      unless instance.valid?
        raise ActiveRecord::RecordInvalid.new(instance)
      end
    end
    
    after(:create) do |planet|
      # Create geosphere
      unless planet.geosphere
        planet.create_geosphere(
          geological_activity: 65,
          tectonic_activity: true,
          crust_composition: {
            'Silicon' => 35.0, 
            'Oxygen' => 25.0, 
            'Magnesium' => 20.0,
            'Iron' => 15.0
          }
        )
      end
      
      # Create biosphere with exotic life potential
      unless planet.biosphere
        planet.create_biosphere(
          biodiversity_index: 0.3,
          habitable_ratio: 0.15
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
    
    # Trait for a more extreme hycean planet
    trait :extreme do
      surface_temperature { 400 }
      known_pressure { 50.0 }
      
      after(:build) do |planet|
        if planet.atmosphere
          planet.atmosphere.pressure = 50.0
        end
      end
      
      after(:create) do |planet|
        if planet.atmosphere
          planet.atmosphere.update(pressure: 50.0, temperature: 400)
        end
      end
    end
    
    # Trait for a cold hycean planet
    trait :cold do
      surface_temperature { 260 }
      
      after(:build) do |planet|
        if planet.atmosphere
          planet.atmosphere.temperature = 260
        end
        
        # Adjust hydrosphere for cold conditions during build
        if planet.hydrosphere && planet.surface_area.present?
          total_water_area = planet.surface_area * 0.85
          ice_area = total_water_area * 0.40
          
          planet.hydrosphere.liquid_bodies = {
            'oceans' => total_water_area * 0.58,  # Reduced from 0.98
            'lakes' => total_water_area * 0.01,
            'rivers' => total_water_area * 0.01,
            'ice_caps' => ice_area,
            'groundwater' => 0
          }
          
          planet.hydrosphere.composition = { 
            'water' => 82, 
            'ammonia' => 12,
            'methane' => 4,
            'salts' => 2 
          }
          
          planet.hydrosphere.state_distribution = { 'liquid' => 60.0, 'solid' => 40.0 }
        end
      end
      
      after(:create) do |planet|
        # Ensure values persist after creation
        if planet.hydrosphere
          planet.hydrosphere.update_columns(
            state_distribution: { 'liquid' => 60.0, 'solid' => 40.0 }
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
            distance: 0.85
          )
        end
      end
    end
  end
end