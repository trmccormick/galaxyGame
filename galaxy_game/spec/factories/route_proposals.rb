FactoryBot.define do
  factory :route_proposal do
    association :proposer, factory: :corporation
    association :consortium, factory: :corporation
    target_system { 'Alpha Centauri' }
    justification { 'Strategic expansion route' }
    estimated_traffic { 100 }
    proposal_fee_paid { 1000.00 }
  end
end
