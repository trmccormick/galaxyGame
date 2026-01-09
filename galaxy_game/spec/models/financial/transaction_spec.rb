# spec/models/financial/transaction_spec.rb
require 'rails_helper'

RSpec.describe Financial::Transaction, type: :model do
  # Create a shared currency for consistency
  let(:currency) { create(:financial_currency) }
  
  # Create a player and account once for the whole test suite
  let(:player) { create(:player) }
  let(:account) { create(:financial_account, accountable: player, currency: currency) }
  let(:recipient) { create(:financial_account, accountable: create(:player), currency: currency) }

  let(:valid_attributes) do
    {
      account: account,
      recipient: recipient,
      amount: 100.00,
      transaction_type: 'transfer',
      description: "Test transaction",
      currency: currency
    }
  end

  describe 'associations' do
    it 'belongs to an account' do
      transaction = Financial::Transaction.create!(valid_attributes)
      expect(transaction.account).to eq(account)
    end

    it 'belongs to a recipient' do
      transaction = Financial::Transaction.create!(valid_attributes)
      expect(transaction.recipient).to eq(recipient)
    end
  end

  describe 'validations' do
    it 'requires a transaction_type' do
      transaction = Financial::Transaction.new(valid_attributes.merge(transaction_type: nil))
      expect(transaction).not_to be_valid
      expect(transaction.errors[:transaction_type]).to include("can't be blank")
    end

    it 'requires a valid transaction_type' do
      expect {
        Financial::Transaction.new(valid_attributes.merge(transaction_type: 'invalid_type'))
      }.to raise_error(ArgumentError, "'invalid_type' is not a valid transaction_type")
    end

    it 'requires an amount' do
      transaction = Financial::Transaction.new(valid_attributes.merge(amount: nil))
      expect(transaction).not_to be_valid
      expect(transaction.errors[:amount]).to include("can't be blank")
    end

    it 'requires amount to be numeric' do
      transaction = Financial::Transaction.new(valid_attributes.merge(amount: 'not_a_number'))
      expect(transaction).not_to be_valid
      expect(transaction.errors[:amount]).to include("is not a number")
    end
  end

  describe 'transaction types' do
    it 'allows deposit transactions' do
      transaction = Financial::Transaction.new(valid_attributes.merge(transaction_type: 'deposit'))
      expect(transaction).to be_valid
    end

    it 'allows withdraw transactions' do
      transaction = Financial::Transaction.new(valid_attributes.merge(transaction_type: 'withdraw'))
      expect(transaction).to be_valid
    end

    it 'allows transfer transactions' do
      transaction = Financial::Transaction.new(valid_attributes.merge(transaction_type: 'transfer'))
      expect(transaction).to be_valid
    end

    it 'allows tax_collection transactions' do
      transaction = Financial::Transaction.new(valid_attributes.merge(transaction_type: 'tax_collection'))
      expect(transaction).to be_valid
    end
  end

  describe 'currency precision' do
    it 'supports high precision for GCC (8 decimal places)' do
      # This will fail if your DB is still scale: 2
      gcc_amount = 0.12345678
      transaction = Financial::Transaction.create!(valid_attributes.merge(amount: gcc_amount))
      expect(transaction.reload.amount).to eq(gcc_amount)
    end
  end  
end