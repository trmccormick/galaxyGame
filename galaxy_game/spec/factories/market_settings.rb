# frozen_string_literal: true

FactoryBot.define do
  factory :market_setting, class: 'Market::Settings' do
    transportation_cost_per_kg { 2.5 }  # Default GCC per kg for Earth-Luna transport
    
    trait :low_transport_cost do
      transportation_cost_per_kg { 1.0 }
    end

    trait :high_transport_cost do
      transportation_cost_per_kg { 5.0 }
    end
  end
end
