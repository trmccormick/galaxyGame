# --- spec/factories/market/market_conditions.rb ---

FactoryBot.define do
  factory :market_condition, class: 'Market::Condition' do
    association :marketplace
    resource { 'Iron Ore' }
    price    { 10.00 }
    supply   { 500 }
    demand   { 500 }

    trait :battery_pack do
      resource { 'Battery Pack' }
    end
  end
end