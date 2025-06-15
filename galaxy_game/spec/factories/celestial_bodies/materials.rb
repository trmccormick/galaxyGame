FactoryBot.define do
  factory :material, class: 'CelestialBodies::Material' do
    sequence(:name) { |n| "Material #{n}" }
    amount { 100.0 }
    state { 'solid' }
    location { 'surface' }
    # ❌ Remove this line - vapor_pressure doesn't exist in the model:
    # vapor_pressure { 1.0 }
    
    association :celestial_body
    
    trait :oxygen do
      name { 'oxygen' }
      state { 'gas' }
      location { 'atmosphere' }
      amount { 50.0 }
    end
    
    trait :iron do
      name { 'iron' }
      state { 'solid' }
      location { 'crust' }
      amount { 1000.0 }
    end
    
    trait :water do
      name { 'water' }
      state { 'liquid' }
      location { 'hydrosphere' }
      amount { 500.0 }
    end
  end
end