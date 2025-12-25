# spec/factories/celestial_bodies/features/skylight_feature.rb
FactoryBot.define do
  factory :skylight_feature, class: 'CelestialBodies::Features::Skylight' do
    association :celestial_body, factory: :moon
    association :parent_feature, factory: :lava_tube_feature
    feature_id { "#{parent_feature.feature_id}_skylight_1" }
    status { 'natural' }
  end
end