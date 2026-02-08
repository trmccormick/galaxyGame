# spec/factories/protoplanets.rb
FactoryBot.define do
    factory :protoplanet, class: 'CelestialBodies::MinorBodies::Protoplanet' do
      sequence(:name) { |n| "Vesta-#{n}" }
      sequence(:identifier) { |n| "PP-#{n}" }
      mass { 2.59e20 }
      radius { 2.627e5 }
      size { 0.041 }  # Vesta's size relative to Earth
      association :solar_system
    end
end