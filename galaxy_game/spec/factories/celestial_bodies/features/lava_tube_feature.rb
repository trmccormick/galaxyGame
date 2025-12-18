# spec/factories/celestial_bodies/features/lava_tube_feature.rb
FactoryBot.define do
  factory :lava_tube_feature, class: 'CelestialBodies::Features::LavaTube' do
    feature_id { 'luna_lt_001' }
    association :celestial_body, factory: :moon
    status { 'natural' }
    
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