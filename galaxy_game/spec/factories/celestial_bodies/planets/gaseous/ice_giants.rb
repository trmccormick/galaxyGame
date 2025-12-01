# spec/factories/celestial_bodies/ice_giants.rb
FactoryBot.define do
  factory :ice_giant, class: 'CelestialBodies::Planets::Gaseous::IceGiant' do
    sequence(:name) { |n| "Neptune-#{n}" }
    sequence(:identifier) { |n| "ICE-GIANT-#{n}" }
    size { 3.88 }
    gravity { 11.15 }
    density { 1.64 }
    radius { 2.4622e7 }
    orbital_period { 60195 }
    mass { 1.024e26 }
    surface_temperature { -214 }
    albedo { 0.29 }
    known_pressure { 1 }
    association :solar_system
    properties { {} }

    # Add this critical callback to ensure properties is set
    before(:create) do |ice_giant|
      ice_giant.properties ||= {}
    end
  end
end