# spec/factories/inventory.rb
FactoryBot.define do
  factory :inventory do
    capacity { 1000 } # Set a default capacity
    association :inventoryable, factory: :base_craft

    trait :with_items do
      after(:create) do |inventory|
        create(:item, inventory: inventory)
      end
    end
  end
end