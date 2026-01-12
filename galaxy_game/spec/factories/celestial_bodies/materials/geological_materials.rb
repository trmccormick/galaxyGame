# spec/factories/geological_materials.rb
FactoryBot.define do
  factory :geological_material, class: 'CelestialBodies::Materials::GeologicalMaterial' do
    name { "Iron" }
    percentage { 15.0 }
    layer { "core" }
    mass { 1000 }
    state { "solid" }
    association :geosphere, factory: :geosphere
  end
end