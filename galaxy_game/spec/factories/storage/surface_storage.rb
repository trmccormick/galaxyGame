FactoryBot.define do
  factory :surface_storage, class: 'Storage::SurfaceStorage' do
    inventory { association :inventory, inventoryable: association(:base_settlement, location: association(:celestial_location, celestial_body: association(:celestial_body))) }
    settlement { inventory.inventoryable }
    celestial_body { inventory.inventoryable.location.celestial_body }
    transient do
      item_type { 'Solid' }
    end

    after(:build) do |surface_storage, evaluator|
      surface_storage.item_type = evaluator.item_type
    end

    trait :with_pile do
      after(:create) do |storage|
        create(:material_pile, 
          surface_storage: storage,
          material_type: 'processed_lunar_regolith',
          amount: 100
        )
      end
    end
  end
end