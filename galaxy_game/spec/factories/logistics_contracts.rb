FactoryBot.define do
  factory :logistics_contract, class: 'Logistics::Contract' do
    association :from_settlement, factory: :base_settlement
    association :to_settlement, factory: :base_settlement
    association :provider, factory: :logistics_provider
    material { 'oxygen' }
    quantity { 100.0 }
    transport_method { :orbital_transfer }
    status { :pending }
    scheduled_at { 1.hour.from_now }
    arrives_at { 3.days.from_now }
    operational_data { { purpose: 'test_transfer' } }
    trait :direct_import do
      transport_method { :direct_import }
      arrives_at { Logistics::Contract::EARTH_LUNA_TRANSIT_DAYS.days.from_now }
      emergency { false }
    end

    trait :contracted_harvesting do
      transport_method { :contracted_harvesting }
      arrives_at { 7.days.from_now }
    end

    trait :emergency_import do
      transport_method { :direct_import }
      emergency { true }
    end
  end
end