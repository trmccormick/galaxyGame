FactoryBot.define do
  factory :celestial_bodies_star_distance, class: 'CelestialBodies::StarDistance' do
    celestial_body { nil }
    star { nil }
    distance { 1.5 }
  end
end
