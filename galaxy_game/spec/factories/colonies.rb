# spec/factories/colonies.rb
FactoryBot.define do
    factory :colony do
      name { "Mars Colony Alpha" }
      capacity { 100 }
      
      after(:create) do |colony|
        # Create domes with current occupancy
        create_list(:dome, 3, colony: colony, capacity: 50, current_occupancy: 25)
      end
    end
  end
  