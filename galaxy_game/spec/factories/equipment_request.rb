FactoryBot.define do
  factory :equipment_request do
    equipment_type { "excavator" }
    quantity_requested { 2 }
    quantity_fulfilled { 0 }
    status { :pending }
    priority { :normal }
    
    # You can add traits for different scenarios
    trait :fulfilled do
      status { :fulfilled }
      quantity_fulfilled { quantity_requested }
    end
    
    trait :partially_fulfilled do
      status { :partially_fulfilled }
      quantity_fulfilled { 1 }
    end
    
    trait :high_priority do
      priority { :high }
    end
    
    trait :critical_priority do
      priority { :critical }
    end
    
    trait :crane do
      equipment_type { "crane" }
      quantity_requested { 1 }
    end
    
    trait :bulldozer do
      equipment_type { "bulldozer" }
      quantity_requested { 3 }
    end
    
    trait :large_quantity do
      quantity_requested { 10 }
    end
  end
end