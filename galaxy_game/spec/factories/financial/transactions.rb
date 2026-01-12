# spec/factories/financial/transactions.rb
FactoryBot.define do
  factory :financial_transaction, class: 'Financial::Transaction' do
    association :account, factory: :financial_account
    association :recipient, factory: :player
    association :currency, factory: :financial_currency
    amount { 100.00 }
    transaction_type { 'transfer' }
    description { "Test transaction" }
  end
end