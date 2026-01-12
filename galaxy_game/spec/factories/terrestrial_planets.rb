# spec/factories/terrestrial_planets.rb
FactoryBot.define do
  factory :terrestrial_planet, class: 'CelestialBodies::Planets::Rocky::TerrestrialPlanet' do
    sequence(:identifier) { |n| "earth-#{n}" }
    name { "Earth" }
    type { "terrestrial_planet" }
    size { 1.0 }
    gravity { 9.8 }
    density { 5.5 }
    orbital_period { 365.25 }
    mass { 5.972e24 }
    radius { 6.371e6 }
    axial_tilt { 23.44 }
    escape_velocity { 11186.0 }
    semi_major_axis { 1.0 }
    surface_area { 510072000000000.0 }
    volume { 1.08321e21 }
    status { 0 }
    known_pressure { 1.0 }
    rotational_period { 24.0 }
    surface_temperature { 288.15 }
    geological_activity { true }
    albedo { 0.3 }
    insolation { 1361.0 }
    composition_type { "rocky" }
    association :solar_system

    # Add traits for different types of terrestrial planets
    trait :mars do
      sequence(:identifier) { |n| "mars-#{n}" }
      name { "Mars" }
      mass { 6.39e23 }
      radius { 3.3895e6 }
      surface_temperature { 210.0 }
      known_pressure { 0.006 }
    end

    trait :venus do
      sequence(:identifier) { |n| "venus-#{n}" }
      name { "Venus" }
      mass { 4.867e24 }
      radius { 6.0518e6 }
      surface_temperature { 737.0 }
      known_pressure { 92.0 }
    end
  end
end