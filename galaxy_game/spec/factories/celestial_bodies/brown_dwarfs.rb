# spec/factories/celestial_bodies/brown_dwarfs.rb
FactoryBot.define do
  factory :brown_dwarf, class: 'CelestialBodies::BrownDwarf' do
    sequence(:name) { |n| "Brown Dwarf #{n}" }
    sequence(:identifier) { |n| "BD-#{n}" }
      mass { 13.0 } # Minimum brown dwarf mass in Jupiter masses
    radius { "69911000" }
    size { 1.0 }
    density { 1.33 }
    gravity { 24.79 }
    orbital_period { 0.0 }
    surface_temperature { 1000 }
    spectral_type { ['L', 'T', 'Y'].sample }
    luminosity { rand(0.00001..0.001) }
    effective_temperature { rand(300..2500) }
    # properties removed; use only model accessors
    association :solar_system
  end
end