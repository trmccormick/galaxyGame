# spec/factories/financial/accounts.rb
FactoryBot.define do
  factory :financial_account, class: 'Financial::Account' do
    balance { 1000.0 }
    currency  # Let FactoryBot infer the association
    lock_version { 0 }

    trait :for_player do
      association :accountable, factory: :player
    end

    trait :for_settlement do
      association :accountable, factory: :base_settlement
    end

    trait :for_organization do
      association :accountable, factory: :organization
    end

    trait :for_colony do
      association :accountable, factory: :colony
    end
  end
end