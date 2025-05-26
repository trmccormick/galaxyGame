# spec/factories/celestial_bodies/stars.rb
FactoryBot.define do
  factory :star, class: 'CelestialBodies::Star' do
    sequence(:name) { |n| "Star #{n}" }
    sequence(:identifier) { |n| "STAR-#{n}" }
    type_of_star { "G" }      # CRITICAL field
    age { 4.6e9 }             # CRITICAL field
    mass { 1.989e30 }         # Solar mass in kg
    radius { 696_340_000.0 }  # Solar radius in meters
    luminosity { 1.0 }
    temperature { 5778 }
    life { 10.0e9 }
    r_ecosphere { 1.0 }
    
    # Only supplemental data in properties
    properties { { 'spectral_class' => 'G2V', 'stellar_class' => 'Main Sequence' } }
    
    association :solar_system
    
    # Add traits for specific star types
    trait :red_dwarf do
      type_of_star { "M" }
      mass { 2.0e29 }
      radius { 139_268_000.0 }
      temperature { 3500 }
      luminosity { 0.001 }
      life { 100.0e9 }
      age { 1.0e9 }
      r_ecosphere { 0.032 }
      properties { { 'spectral_class' => 'M5V', 'stellar_class' => 'Main Sequence' } }
    end
    
    trait :binary_star do
      after(:create) do |star|
        create(:star, 
          solar_system: star.solar_system, 
          mass: 1.5e30,
          type_of_star: "K",
          luminosity: 0.8,
          properties: { 'spectral_class' => 'K2V', 'stellar_class' => 'Main Sequence' }
        )
      end
    end
  end
end
