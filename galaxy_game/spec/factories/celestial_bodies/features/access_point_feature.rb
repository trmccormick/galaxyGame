# spec/factories/celestial_bodies/features/access_point_feature.rb
FactoryBot.define do
  factory :access_point_feature, class: 'CelestialBodies::Features::AccessPoint' do
    association :celestial_body, factory: :moon
    association :parent_feature, factory: :lava_tube_feature
    feature_id { "#{parent_feature.feature_id}_access_1" }
    status { 'natural' }
  end
end