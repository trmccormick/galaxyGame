# spec/factories/gases.rb
FactoryBot.define do
    factory :gas, class: 'CelestialBodies::Materials::Gas' do
      sequence(:name) { |n| "Gas #{n}" }
      percentage { 50.0 } # Default percentage
      molar_mass { 28.0 } # Default molar mass for air-like gas
  
      # You might want to create an associated `atmosphere` if needed
      association :atmosphere
  
      trait :with_high_percentage do
        percentage { 90.0 }
      end
  
      trait :with_low_percentage do
        percentage { 10.0 }
      end
  
      trait :co2 do
        name { 'CO2' }
        molar_mass { 44.01 }
      end
  
      trait :n2 do
        name { 'N2' }
        molar_mass { 28.02 }
      end
  
      trait :o2 do
        name { 'O2' }
        molar_mass { 32.0 }
      end
  
      trait :ar do
        name { 'Ar' }
        molar_mass { 39.95 }
      end
  
      # Add any additional traits or default values as needed
    end
  end
  