FactoryBot.define do
  factory :market_order, class: 'Market::Order' do
    association :market_condition
    association :base_settlement
    orderable { base_settlement }
    resource { 'water' }
    quantity { 10 }
    order_type { :buy }
  end
end