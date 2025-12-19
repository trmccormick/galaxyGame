# spec/factories/celestial_bodies/features/canyon_feature.rb
FactoryBot.define do
  factory :canyon_feature, class: 'CelestialBodies::Features::Canyon' do
    celestial_body { association :moon }
    feature_id { 'luna_cn_001' }
    feature_type { 'canyon' }
    status { 'natural' }
    static_data {
      {
        'dimensions' => {
          'length_m' => 12000,
          'width_m' => 500,
          'depth_m' => 200,
          'volume_m3' => 1200000000
        },
        'formation' => 'tectonic_rifting',
        'conversion_suitability' => { 'habitat' => true },
        'segments' => ['north', 'central', 'south']
      }
    }
      type { 'CelestialBodies::Features::Canyon' }
  end
end
