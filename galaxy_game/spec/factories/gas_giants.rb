# spec/factories/gas_giants.rb
FactoryBot.define do
    factory :gas_giant, class: 'CelestialBodies::GasGiant' do
      name { 'Jupiter' }
      mass { 1.898e27 }
      radius { 6.9911e7 }
      size { 11.2 }  # Jupiter's size relative to Earth
      association :solar_system
    end
end