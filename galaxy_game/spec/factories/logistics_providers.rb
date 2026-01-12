FactoryBot.define do
  factory :logistics_provider, class: 'Logistics::Provider' do
    sequence(:name) { |n| "Test Logistics Provider #{n}" }
    sequence(:identifier) { |n| "TLP-#{n}" }
    association :organization, factory: :organization
    reliability_rating { 4.5 }
    base_fee_per_kg { 10.0 }
    speed_multiplier { 1.0 }
    capabilities { ['orbital_transfer', 'surface_conveyance'] }
    cost_modifiers { { 'bulk_discount_thresholds' => [], 'orbital_transfer_discount' => 0.9 } }
    time_modifiers { { 'orbital_transfer_speedup' => 0.8 } }
  end
end