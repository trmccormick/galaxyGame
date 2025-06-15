FactoryBot.define do
  factory :satellite, class: 'CelestialBodies::Satellites::Satellite' do
    sequence(:name) { |n| "Satellite #{n}" }
    sequence(:identifier) { |n| "SAT-#{n}" }
    mass { "1.0e22" }  # String format like your other factories
    radius { 1.737e6 }
    gravity { 1.62 }
    orbital_period { 27.3 }
    rotational_period { 27.3 }  # Add this field
    density { 3.34 }
    size { 0.27 }
    surface_temperature { 250 }
    albedo { 0.12 }
    known_pressure { 0.0 }
    association :solar_system
    association :parent_celestial_body, factory: :terrestrial_planet
    properties { {} }
    
    # Ensure properties is set (matching your pattern)
    before(:create) do |satellite|
      satellite.properties ||= {}
    end
    
    trait :tidally_locked do
      rotational_period { orbital_period }
      properties { { 'tidal_lock_status' => 'locked' } }
    end
    
    trait :large do
      name { "Large Satellite" }
      mass { "7.342e22" }  # Moon-sized
      radius { 1.737e6 }
      gravity { 1.62 }
    end
    
    trait :small do
      name { "Small Satellite" }
      mass { "1.0e20" }
      radius { 500000 }
      gravity { 0.1 }
    end
  end
end