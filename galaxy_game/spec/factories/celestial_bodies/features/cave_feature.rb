# spec/factories/celestial_bodies/features/cave_feature.rb
FactoryBot.define do
  factory :cave_feature, class: 'CelestialBodies::Features::Cave' do
    association :celestial_body, factory: :moon
    feature_id { 'luna_cave_001' }
    status { 'natural' }
  end
end
