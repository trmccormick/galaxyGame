# spec/factories/item.rb
FactoryBot.define do
  factory :item do
    name { "Battery Pack" }
    amount { 1 }
    storage_method { "bulk_storage" }
    association :owner, factory: :player
    association :inventory

    trait :raw_material do
      name { "Lunar Regolith" }  # Using existing material from JSON
      storage_method { "bulk_storage" }
      material_type { :raw_material }
    end

    trait :container do
      name { "Large Plastic Crate" }
      storage_method { "container" }
    end
  end
end