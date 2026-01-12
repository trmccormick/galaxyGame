# spec/factories/financial/bonds.rb
FactoryBot.define do
  factory :financial_bond, class: 'Financial::Bond' do
    association :issuer, factory: :player
    association :holder, factory: :player
    association :currency, factory: :financial_currency
    
    amount { 1000.0 }
    interest_rate { 5.0 }
    issued_at { Time.current }
    due_at { 1.year.from_now }
    status { 'issued' }
    description { 'Test bond' }
    
    trait :paid do
      status { 'paid' }
    end
    
    trait :defaulted do
      status { 'defaulted' }
    end
  end
end