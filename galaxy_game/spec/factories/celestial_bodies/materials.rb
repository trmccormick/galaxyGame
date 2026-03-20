FactoryBot.define do
  factory :material, class: 'CelestialBodies::Material' do
    name { 'iron' }
    amount { 100.0 }
    state { 'solid' }
    location { 'surface' }
    layer { 'unknown' }
    
    association :celestial_body
    
    trait :oxygen do
      name { 'oxygen' }
      state { 'gas' }
      location { 'atmosphere' }
      layer { 'unknown' }
      amount { 50.0 }
    end

    trait :water do
      name { 'water' }
      state { 'liquid' }
      location { 'hydrosphere' }
      layer { 'unknown' }
      amount { 500.0 }
    end
  end
end