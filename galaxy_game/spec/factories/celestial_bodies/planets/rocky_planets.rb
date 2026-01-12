# In your factories file
FactoryBot.define do
  factory :super_earth, class: 'CelestialBodies::Planets::Rocky::SuperEarth' do
    sequence(:name) { |n| "SuperEarth-#{n}" }
    sequence(:identifier) { |n| "SPET-#{n}" }
    mass { 5.0e24 } # 5 Earth masses
    radius { 9.5e6 } # 1.5x Earth radius
    # Other attributes...
  end
  
  factory :carbon_planet, class: 'CelestialBodies::Planets::Rocky::CarbonPlanet' do
    sequence(:name) { |n| "Carbon-#{n}" }
    sequence(:identifier) { |n| "CRBN-#{n}" }
    mass { 4.0e24 }
    radius { 7.0e6 }
    # Other attributes...
  end
  
  factory :lava_world, class: 'CelestialBodies::Planets::Rocky::LavaWorld' do
    sequence(:name) { |n| "Vulcan-#{n}" }
    sequence(:identifier) { |n| "LAVA-#{n}" }
    mass { 3.5e24 }
    radius { 6.5e6 }
    surface_temperature { 1200 }
    # Other attributes...
  end
end