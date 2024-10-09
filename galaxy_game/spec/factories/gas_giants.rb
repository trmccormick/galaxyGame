# spec/factories/gas_giants.rb
FactoryBot.define do
    factory :gas_giant do
      name { 'Jupiter' }
      mass { 1.898e27 }
      radius { 6.9911e7 }
      association :solar_system
    end
end