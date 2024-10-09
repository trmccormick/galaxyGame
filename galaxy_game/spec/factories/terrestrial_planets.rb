# spec/factories/terrestrial_planets.rb
FactoryBot.define do
  factory :terrestrial_planet do
    name { "Earth" }
    size { 1.0 }
    gravity { 9.8 }
    density { 5.5 }
    orbital_period { 365.25 }
    mass { 5.972e24 }
    radius { 6.37e6 }
    gas_quantities { { "Nitrogen" => 780800, "Oxygen" => 209500 } }
    materials { { "Iron" => 1000 } }
    surface_temperature { 288.15 }
    atmosphere_composition { { "Nitrogen" => 780800, "Oxygen" => 209500 } }
    albedo { 0.3 }
    insolation { 1361 }
    distance_from_star { 1.0 } # Distance from the star in AU (Astronomical Units)
    association :solar_system

    # Add traits for other terrestrial planets
    trait :mercury do
      name { "Mercury" }
      size { 0.383 }
      gravity { 3.7 }
      density { 5.427 }
      orbital_period { 88.0 }
      mass { 3.285e23 }
      radius { 2.44e6 }
      gas_quantities { {} } # Almost no atmosphere
      materials { { "Iron" => 700, "Silicate" => 300 } }
      surface_temperature { 440 }
      atmosphere_composition { {} }
      albedo { 0.12 }
      insolation { 9126 }
      distance_from_star { 0.39 } # Distance from the star in AU
    end

    trait :venus do
      name { "Venus" }
      size { 0.949 }
      gravity { 8.87 }
      density { 5.243 }
      orbital_period { 224.7 }
      mass { 4.867e24 }
      radius { 6.05e6 }
      gas_quantities { { "Carbon Dioxide" => 965000, "Nitrogen" => 35000 } }
      materials { { "Iron" => 850, "Silicate" => 150 } }
      surface_temperature { 737 }
      atmosphere_composition { { "Carbon Dioxide" => 965000, "Nitrogen" => 35000 } }
      albedo { 0.75 }
      insolation { 2613 }
      distance_from_star { 0.72 } # Distance from the star in AU
    end

    trait :mars do
      name { "Mars" }
      size { 0.532 }
      gravity { 3.71 }
      density { 3.933 }
      orbital_period { 687 }
      mass { 6.39e23 }
      radius { 3.39e6 }
      gas_quantities { { "Carbon Dioxide" => 950000, "Nitrogen" => 27000, "Argon" => 16000 } }
      materials { { "Iron" => 600, "Silicate" => 400 } }
      surface_temperature { 210 }
      atmosphere_composition { { "Carbon Dioxide" => 950000, "Nitrogen" => 27000, "Argon" => 16000 } }
      albedo { 0.25 }
      insolation { 586 }
      distance_from_star { 1.52 } # Distance from the star in AU
    end
  end
end