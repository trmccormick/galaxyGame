FactoryBot.define do
  factory :transaction do
    # Create an account with a player as its accountable
    association :account, factory: :account, accountable: association(:player)
    association :recipient, factory: :player
    amount { 100.00 }
    transaction_type { 'transfer' }
    description { "Test transaction" }
  end
end