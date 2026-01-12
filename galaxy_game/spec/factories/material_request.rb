FactoryBot.define do
  factory :material_request do
    association :requestable, factory: :construction_job
    
    # Use the correct attribute names for your model
    material_name { "Steel" }  # Change this to match your model attribute
    quantity_requested { 100 }
    status { 'pending' }
    
    trait :fulfilled do
      status { 'fulfilled' }
      quantity_fulfilled { quantity_requested }
      fulfilled_at { Time.current }
    end
  end
end