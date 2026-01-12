FactoryBot.define do
  factory :hot_jupiter, class: 'CelestialBodies::Planets::Gaseous::HotJupiter' do
    sequence(:name) { |n| "Hot Jupiter-#{n}" }
    sequence(:identifier) { |n| "HOT-JUP-#{n}" }
    size { 12.0 }
    gravity { 25.0 }
    density { 1.3 }
    radius { 8.0e7 }
    orbital_period { 3.5 * 24 * 3600 } # 3.5 days in seconds
    mass { 2.0e27 }
    surface_temperature { 1200 } # Hot!
    albedo { 0.3 }
    known_pressure { 1 }
    association :solar_system
    properties { {} }
    
    # Add this critical callback to ensure properties is set
    before(:create) do |hot_jupiter|
      hot_jupiter.properties ||= {}
    end
  end
end