# spec/factories/gas_giants.rb
FactoryBot.define do
    factory :gas_giant, class: 'CelestialBodies::Planets::Gaseous::GasGiant' do
      sequence(:name) { |n| "Jupiter-#{n}" }
      sequence(:identifier) { |n| "GG-#{n}" }
      mass { 1.898e27 }
      radius { 6.9911e7 }
      size { 11.2 }  # Jupiter's size relative to Earth
      density { 1.33 }  # Jupiter's density in g/cm³
      association :solar_system
    end
end