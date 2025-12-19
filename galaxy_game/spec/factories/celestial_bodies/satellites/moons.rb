# spec/factories/celestial_bodies/moons.rb
FactoryBot.define do
  factory :moon, class: 'CelestialBodies::Satellites::Moon' do
    sequence(:name) { |n| "Moon #{n}" }
    sequence(:identifier) { |n| "moon_#{n}" }
    size { 1000.0 }
    mass { "7.342e22" }  # String format to match schema
    radius { 1.737e6 }
    orbital_period { 27.3 }
    rotational_period { 27.3 }  # ✅ Tidally locked by default
    type { 'CelestialBodies::Satellites::Moon' }
    
    association :parent_celestial_body, factory: :terrestrial_planet
    association :solar_system
    
    trait :small do
      mass { "1.0e20" }
      radius { 5.0e5 }
      name { "Small Moon" }
    end
    
    trait :large do
      mass { "1.5e23" }
      radius { 2.5e6 }
      name { "Large Moon" }
    end
    
    trait :tidally_locked do
      rotational_period { orbital_period }
    end
    
    trait :fast_rotation do
      rotational_period { 0.5 }  # 12 hour day
    end
    
    trait :slow_rotation do
      rotational_period { 100.0 }  # Very slow rotation
    end
    
    trait :synchronous do
      # Rotation matches parent planet's day
      after(:build) do |moon|
        if moon.parent_celestial_body&.rotational_period
          moon.rotational_period = moon.parent_celestial_body.rotational_period
        end
      end
    end
  end
end