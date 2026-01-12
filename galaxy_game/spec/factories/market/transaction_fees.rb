FactoryBot.define do
  factory :transaction_fee, class: 'Market::TransactionFee' do
    fee_type { 'percentage' }
    percentage { 2.5 }
    fixed_amount { nil }
  end
end