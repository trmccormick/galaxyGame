# spec/factories/dwarf_planets.rb
FactoryBot.define do
    factory :dwarf_planet, class: 'CelestialBodies::MinorBodies::DwarfPlanet' do
      sequence(:name) { |n| "Pluto-#{n}" }
      sequence(:identifier) { |n| "DP-#{n}" }
      mass { 1.309e22 }
      radius { 1.188e6 }
      size { 0.18 }  # Pluto's size relative to Earth
      association :solar_system
    end
end