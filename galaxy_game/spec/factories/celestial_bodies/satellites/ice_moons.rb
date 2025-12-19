FactoryBot.define do
  factory :ice_moon, class: 'CelestialBodies::Satellites::IceMoon' do
    sequence(:name) { |n| "Ice Moon-#{n}" }
    sequence(:identifier) { |n| "IMOON-#{n}" }
    mass { 4.8e22 }
    radius { 1.561e6 }
    density { 1.9 }
    surface_temperature { 100 }
    size { 1.0 }
    association :solar_system
    properties { {} }

    after(:build) do |moon|
      # Build hydrosphere with high ice coverage
      moon.hydrosphere ||= build(:hydrosphere,
        celestial_body: moon,
        liquid_bodies: { 'oceans' => 0, 'lakes' => 0, 'rivers' => 0, 'ice_caps' => 1.4e6, 'groundwater' => 0 },
          composition: { 'water' => 95, 'ammonia' => 3, 'salts' => 2 },
          state_distribution: { 'solid' => 95, 'liquid' => 5, 'gas' => 0 },
        temperature: moon.surface_temperature,
        pressure: 0.01
      )
    end
  end
end
