# spec/factories/domes.rb
FactoryBot.define do
    factory :dome do
      name { "Dome #{Faker::Number.unique.number(digits: 4)}" }  # Unique name with random number
      capacity { 50 }  # Default capacity; you can change it as needed
      current_occupancy { 0 }  # Start with zero occupancy
  
      association :colony  # Automatically associate with a colony
    end
end
  