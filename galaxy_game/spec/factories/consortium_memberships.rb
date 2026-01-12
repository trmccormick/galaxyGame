FactoryBot.define do
  factory :consortium_membership do
    association :consortium, factory: :consortium
    association :member, factory: :corporation
    ownership_percentage { 10.0 }
    membership_terms { { 'seat_on_board' => false, 'preferential_rates' => 0.0 } }
    voting_power { 1 }
    investment_amount { 100_000 }
  end
end
