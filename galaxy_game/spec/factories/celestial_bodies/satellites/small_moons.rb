FactoryBot.define do
  factory :small_moon, class: 'CelestialBodies::Satellites::SmallMoon' do
    sequence(:name) { |n| "Small Moon-#{n}" }
    sequence(:identifier) { |n| "SMOON-#{n}" }
      mass { 1.8e15 } 
      radius { 6200 }
      density { 1.5 }
      surface_temperature { 120 }
      size { 1.0 }
    association :solar_system
    properties { {} }

    after(:build) do |moon|
      # Optionally build geosphere for small moons
      moon.geosphere ||= build(:geosphere,
        celestial_body: moon,
        temperature: moon.surface_temperature,
        pressure: 0.0,
        geological_activity: 1,
        tectonic_activity: false,
        crust_composition: { 'Silicon' => 30.0, 'Oxygen' => 20.0 },
        core_composition: { 'Iron' => 60.0, 'Nickel' => 40.0 },
        skip_simulation: true
      )
    end
  end
end
