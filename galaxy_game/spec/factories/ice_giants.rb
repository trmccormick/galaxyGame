# spec/factories/ice_giants.rb
FactoryBot.define do
    factory :ice_giant do
      name { 'Neptune' }
      mass { 1.024e26 }
      radius { 2.4622e7 }
      association :solar_system
    end
end