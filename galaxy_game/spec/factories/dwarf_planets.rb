# spec/factories/dwarf_planets.rb
FactoryBot.define do
    factory :dwarf_planet do
      name { 'Pluto' }
      mass { 1.309e22 }
      radius { 1.188e6 }
      association :solar_system
    end
end