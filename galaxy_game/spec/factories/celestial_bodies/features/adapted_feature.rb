FactoryBot.define do
  factory :adapted_feature, class: 'CelestialBodies::Features::AdaptedFeature' do
    feature_id { 'luna_lt_001' }
    feature_type { 'lava_tube' }
      celestial_body { association :moon }
    status { 'natural' }
      type { 'CelestialBodies::Features::AdaptedFeature' }
  end
end
