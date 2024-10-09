# spec/factories/celestial_bodies.rb
FactoryBot.define do
  factory :celestial_body, class: 'CelestialBodies::CelestialBody' do
    name { "Mars" }
    size { 0.53 }
    gravity { 3.71 }
    density { 3.93 }
    mass { 6.4171e23 }
    radius { 3_390_000.0 }
    distance_from_star { 1.0 }
    status { "active" }
    orbital_period { 687.0 }
    albedo { 0.25 }
    insolation { 580 }
    surface_temperature { -60 }
    known_pressure { 0.006 }
    water_volume { 0.0 }
    solar_system

    after(:create) do |celestial_body|
      celestial_body.create_atmosphere(gas_composition: { 'CO2' => 0.04, 'CH4' => 0.001 }) unless celestial_body.atmosphere.present?
      celestial_body.create_biosphere(temperature_tropical: 290, temperature_polar: 260) unless celestial_body.biosphere.present?
      celestial_body.create_geosphere(rock_types: { 'basalt' => 0.6, 'granite' => 0.3 }) unless celestial_body.geosphere.present?
      celestial_body.create_hydrosphere(
        liquid_name: 'unknown',
        liquid_volume: 0,
        lakes: 0,
        rivers: 0,
        oceans: 0,
        ice: 0
      ) unless celestial_body.hydrosphere.present?
    end

    trait :with_solar_system do
      association :solar_system
    end

    trait :without_solar_system do
      solar_system { nil }
    end
  end

  factory :brown_dwarf, parent: :celestial_body, class: 'CelestialBodies::BrownDwarf' do
    name { "Brown Dwarf" }
    size { 0.5 }
    mass { 1.0e25 }
    radius { 7_000_000.0 }
    distance_from_star { nil }
    solar_system { nil }

    gravity { 0.2 }
    density { 0.8 }
    surface_temperature { 1200 }
    known_pressure { 10.0 }
  end

  factory :sub_brown_dwarf, parent: :celestial_body, class: 'CelestialBodies::SubBrownDwarf' do
    name { "Sub Brown Dwarf" }
    size { 0.2 }
    mass { 5.0e24 }  # Lower mass than typical brown dwarfs, but larger than planets
    radius { 5_000_000.0 }
    distance_from_star { nil }
    solar_system { nil }

    gravity { 0.1 }
    density { 0.5 }
    surface_temperature { 400 }  # Generally lower than brown dwarfs due to lack of fusion
    known_pressure { 5.0 }

    after(:create) do |celestial_body|
      # Since sub-brown dwarfs are free-floating, no association to a solar system by default
      celestial_body.create_atmosphere(gas_composition: { 'H2' => 0.7, 'He' => 0.3 }) unless celestial_body.atmosphere.present?
    end
  end

  factory :earth, parent: :celestial_body, class: 'CelestialBodies::Earth' do
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
    surface_temperature { 15 }
    known_pressure { 1.0 }
    water_volume { 1.386e21 }

    after(:create) do |celestial_body|
      celestial_body.create_atmosphere(gas_composition: { 'N2' => 0.78, 'O2' => 0.21, 'CO2' => 0.0004 }) unless celestial_body.atmosphere.present?
      celestial_body.create_biosphere(temperature_tropical: 300, temperature_polar: 260) unless celestial_body.biosphere.present?
      celestial_body.create_geosphere(rock_types: { 'granite' => 0.5, 'basalt' => 0.4 }) unless celestial_body.geosphere.present?
      celestial_body.create_hydrosphere(
        liquid_name: 'water',
        liquid_volume: 1.386e21,
        lakes: 20,
        rivers: 100,
        oceans: 1,
        ice: 5
      ) unless celestial_body.hydrosphere.present?
    end
  end
end

