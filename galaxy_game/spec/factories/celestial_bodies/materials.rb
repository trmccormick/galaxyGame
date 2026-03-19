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
      layer { 'unknown' }  # Use 'unknown' for non-standard layers
      amount { 50.0 }
    end
    
    trait :iron do
      name { 'iron' }
      state { 'solid' }
      location { 'geosphere' } # FIX: match escalation logic
      layer { 'crust' }  # Valid enum value
      amount { 1000.0 }
    end

    trait :water do
      name { 'water' }
      state { 'liquid' }
      location { 'hydrosphere' }
      layer { 'unknown' }  # Use 'unknown' for non-standard layers
      amount { 500.0 }
    end
  end
end