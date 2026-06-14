# frozen_string_literal: true

FactoryBot.define do
  factory :manifest, class: 'Logistics::Manifest' do
    sequence(:manifest_id) { |n| "MANIFEST-#{SecureRandom.hex(8)}-#{n}" }
    association :source_settlement, factory: :base_settlement
    association :destination_settlement, factory: :base_settlement
    items { [{ resource: 'water', quantity: 100, category: 'consumable', unit_cost: 5.0 }] }
    total_items { 100 }
    total_cost { 500.0 }
    status { :pending }
    manifest_type { 0 }
    estimated_revenue_gcc { 0.0 }
    total_weight_kg { 100.0 }

    trait :in_transit do
      status { :in_transit }
    end

    trait :delivered do
      status { :delivered }
    end

    trait :failed do
      status { :failed }
    end
    
    # Export manifest traits for return cargo optimization testing
    trait :export_manifest do
      manifest_type { 1 }
      items { [{ resource: 'Helium-3', quantity_kg: 10.0, category: 'rare_isotope', market_price_gcc_per_kg: 5_000.0, total_value: 50_000.0 }] }
      estimated_revenue_gcc { 50_000.0 }
      status { :pending }
    end
    
    trait :luna_export do
      export_manifest
      items { 
        [
          { resource: 'Helium-3', quantity_kg: 10.0, category: 'rare_isotope', market_price_gcc_per_kg: 5_000.0, total_value: 50_000.0 },
          { resource: 'Regolith Samples', quantity_kg: 1_000.0, category: 'raw_material', market_price_gcc_per_kg: 2.5, total_value: 2_500.0 }
        ] 
      }
      estimated_revenue_gcc { 52_500.0 }
      total_weight_kg { 1_010.0 }
    end
  end
end
