FactoryBot.define do
  factory :price_history, class: 'Market::PriceHistory' do
    association :market_condition
    price { 100.0 }
    created_at { Time.now }
  end
end