# spec/factories/items.rb
FactoryBot.define do
  factory :item do
    name { "Battery Pack" }
    amount { 1 }
    material_type { "consumable" }
    storage_method { "bulk_storage" }
    association :owner, factory: :player
    association :inventory

    trait :container do
      name { "Large Plastic Crate" }
      material_type { "container" }
      storage_method { "container" }
    end

    trait :regolith do
      name { "Regolith" }
      material_type { "raw_material" }
      storage_method { "bulk_storage" }
      metadata { {
        source_body: "LUNA-01",
        collection_location: "Mare Tranquillitatis"
      } }
    end
  end
end