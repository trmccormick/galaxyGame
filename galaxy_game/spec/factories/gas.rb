# spec/factories/gases.rb
FactoryBot.define do
    factory :gas do
      sequence(:name) { |n| "Gas #{n}" }
      percentage { 50.0 } # Default percentage
  
      # You might want to create an associated `celestial_body` if needed
      association :celestial_body
  
      trait :with_high_percentage do
        percentage { 90.0 }
      end
  
      trait :with_low_percentage do
        percentage { 10.0 }
      end
  
      trait :co2 do
        name { 'CO2' }
      end
  
      # Add any additional traits or default values as needed
    end
  end
  