FactoryBot.define do
  factory :atmosphere, class: 'CelestialBodies::Spheres::Atmosphere' do
    association :celestial_body
    temperature { 20 }
    pressure { 1013 }
  end
end