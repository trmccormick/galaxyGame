# spec/factories/celestial_bodies/features/lava_tube_feature.rb
FactoryBot.define do
  factory :lava_tube_feature, aliases: [:lava_tube], class: 'CelestialBodies::Features::LavaTube' do
    feature_id { 'luna_lt_001' }
    association :celestial_body, factory: :moon
    association :settlement, factory: :settlement
    status { 'natural' }
    
    static_data do
      {
        'name' => 'Luna Lava Tube Alpha',
        'dimensions' => {
          'length_m' => 5000,
          'width_m' => 50,
          'height_m' => 30,
          'estimated_volume_m3' => 7500000
        },
        'attributes' => {
          'natural_shielding' => 0.8,
          'thermal_stability' => 0.9
        },
        'conversion_suitability' => {
          'habitat' => 0.85,
          'estimated_cost_multiplier' => 1.2,
          'advantages' => ['natural_shielding', 'thermal_stability'],
          'challenges' => ['access_difficulty']
        },
        'priority' => 'high',
        'strategic_value' => ['habitation', 'manufacturing']
      }
    end
    
    trait :surveyed do
      status { 'surveyed' }
      discovered_by { 1 }
      discovered_at { 1.day.ago }
    end
    
    trait :enclosed do
      status { 'enclosed' }
      adapted_at { 1.day.ago }
    end
    
    trait :pressurized do
      status { 'pressurized' }
      adapted_at { 1.day.ago }
    end
  end
end