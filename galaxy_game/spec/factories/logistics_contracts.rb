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
    operational_data { { purpose: 'test_transfer' } }
  end
end