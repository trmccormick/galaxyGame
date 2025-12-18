# spec/factories/celestial_bodies/features/valley_feature.rb
FactoryBot.define do
  factory :valley_feature, class: 'CelestialBodies::Features::Valley' do
    association :celestial_body, factory: :moon
    feature_id { 'luna_valley_001' }
    status { 'natural' }
  end
end
