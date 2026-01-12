# spec/factories/celestial_bodies/features/crater_feature.rb
FactoryBot.define do
  factory :crater_feature, class: 'CelestialBodies::Features::Crater' do
    feature_id { 'luna_cr_001' } # Shackleton by default
    association :celestial_body, factory: :moon
    status { 'natural' }
    
    trait :catalog do
      feature_id { 'luna_cr_cat_0001' }
    end
  end
end