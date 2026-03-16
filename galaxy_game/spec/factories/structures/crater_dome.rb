# spec/factories/structures/crater_dome.rb
FactoryBot.define do
    # Removed obsolete crater_dome factory
      after(:build) do |dome|
        dome.status = "under_construction"
      end
    end
    
    trait :operational do
      status { "operational" }
    end
    
    # Dome with specific layer
    trait :with_primary_layer do
      status { "primary_layer_complete" }
    end
    
    trait :with_secondary_layer do
      status { "secondary_layer_complete" }
    end
  end
end