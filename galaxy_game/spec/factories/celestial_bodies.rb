# spec/factories/celestial_bodies.rb
FactoryBot.define do
  factory :celestial_body do
    name { "Mars" }
    size { 0.53e0 }
    gravity { 0.371e1 }
    density { 0.393e1 }
    mass { 6.4171e23 }
    radius { 3_390_000.0 }
    distance_from_star { 1.0 }
    status { "active" }
    orbital_period { 687.0 }
    albedo { 0.25 }
    insolation { 580 }
    surface_temperature { -60 }   # Updated to use surface_temperature
    known_pressure { 0.006 }      # Pressure on Mars in bars

    # Hydrosphere attributes
    water_volume { 0.0 }  # Total water volume
    lakes { 0.0 }         # Volume of lakes
    rivers { 0.0 }        # Volume of rivers
    oceans { 0.0 }        # Volume of oceans
    ice { 0.0 }           # Volume of ice

    # Materials and atmosphere related adjustments can be added as needed

    solar_system # Ensure the celestial body is part of a solar system

    trait :with_solar_system do
      association :solar_system
    end
  
    trait :without_solar_system do
      solar_system { nil }
    end 
  end

  factory :brown_dwarf, parent: :celestial_body do
    name { "Brown Dwarf" }
    size { 0.5 }  # Example size for a brown dwarf
    mass { 1.0e25 }  # Example mass for a brown dwarf
    radius { 7_000_000.0 }  # Example radius for a brown dwarf
    distance_from_star { nil }  # Brown dwarfs are not in a solar system
    solar_system { nil }  # Ensure no solar system is associated

    # Specific attributes for a brown dwarf
    trait :brown_dwarf_specific do
      gravity { 0.2 }
      density { 0.8 }
      surface_temperature { 1200 }  # Example temperature for a brown dwarf
      known_pressure { 10.0 }       # Example higher pressure for a brown dwarf in bars
    end
  end

  factory :earth, parent: :celestial_body do
    name { "Earth" }
    size { 1.0 }
    gravity { 9.807 }
    density { 5.514 }
    mass { 5.972e24 }
    radius { 6_371_000.0 }
    distance_from_star { 1.0 }
    status { "active" }
    orbital_period { 365.25 }
    albedo { 0.306 }
    insolation { 1361 }
    surface_temperature { 15 }    # Average surface temperature in Celsius
    known_pressure { 1.0 }        # Earth's pressure at sea level in bars

    # Hydrosphere attributes
    water_volume { 1.386e21 }  # Total water volume
    lakes { 1.25e16 }          # Volume of lakes
    rivers { 2.12e13 }         # Volume of rivers
    oceans { 1.332e21 }        # Volume of oceans
    ice { 2.0e19 }             # Volume of ice
  end
end

