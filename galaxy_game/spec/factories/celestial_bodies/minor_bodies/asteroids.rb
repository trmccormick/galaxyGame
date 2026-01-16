# spec/factories/celestial_bodies/minor_bodies/asteroids.rb
FactoryBot.define do
  factory :asteroid, class: 'CelestialBodies::MinorBodies::Asteroid' do
    sequence(:name) { |n| "Asteroid-#{n}" }
    sequence(:identifier) { |n| "AST-#{n}" }
    mass { 1.0e15 }  # Typical asteroid mass
    radius { 5000 }  # Typical asteroid radius in meters
    size { 0.001 }   # Very small relative to Earth
    association :solar_system
  end
end