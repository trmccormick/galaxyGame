# spec/factories/moons.rb
FactoryBot.define do
    factory :moon do
      name { 'Moon' }
      mass { 7.342e22 }
      radius { 1.737e6 }
      association :solar_system
    end
end