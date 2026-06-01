FactoryBot.define do
  factory :manifest, class: 'Logistics::Manifest' do
    sequence(:manifest_id) { |n| "MANIFEST-#{SecureRandom.hex(8)}-#{n}" }
    association :source_settlement, factory: :base_settlement
    association :destination_settlement, factory: :base_settlement
    items { [{ resource: 'water', quantity: 100, category: 'consumable', unit_cost: 5.0 }] }
    total_items { 100 }
    total_cost { 500.0 }
    status { :pending }

    trait :in_transit do
      status { :in_transit }
    end

    trait :delivered do
      status { :delivered }
    end

    trait :failed do
      status { :failed }
    end
  end
end
