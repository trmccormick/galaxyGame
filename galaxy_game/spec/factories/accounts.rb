FactoryBot.define do
  factory :account, class: 'Financial::Account' do
    balance { 1000.0 }
    association :currency, factory: :financial_currency
    
    # By default, no accountable is assigned
    # This allows explicit assignment in tests
    
    # Add traits for different account owners
    trait :for_player do
      association :accountable, factory: :player, strategy: :build
    end
    
    trait :for_settlement do
      association :accountable, factory: :base_settlement, strategy: :build
    end
    
    trait :for_organization do
      association :accountable, factory: :organization, strategy: :build
    end
    
    trait :for_colony do
      association :accountable, factory: :colony, strategy: :build
    end
  end
end