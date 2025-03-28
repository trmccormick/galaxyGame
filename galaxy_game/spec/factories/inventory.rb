# spec/factories/inventory.rb
FactoryBot.define do
  factory :inventory do
    association :inventoryable, factory: :base_settlement

    trait :with_items do
      after(:create) do |inventory|
        create(:item, 
          inventory: inventory,
          name: "Battery Pack",
          amount: 500,
          storage_method: "bulk_storage"
        )
      end
    end
  end
end