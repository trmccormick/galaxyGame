# spec/models/transaction_spec.rb
require 'rails_helper'

RSpec.describe Transaction, type: :model do
  # Create a player and account once for the whole test suite
  let(:player) { create(:player) }
  let(:account) { create(:account, accountable: player) }
  let(:recipient) { create(:player) }

  # Use these in all transaction creation/building
  let(:valid_attributes) do
    {
      account: account,
      recipient: recipient,
      amount: 100.00,
      transaction_type: 'transfer',
      description: "Test transaction"
    }
  end

  describe 'associations' do
    it 'belongs to an account' do
      transaction = Transaction.create!(valid_attributes)
      expect(transaction.account).to eq(account)
    end

    it 'belongs to a recipient' do
      transaction = Transaction.create!(valid_attributes)
      expect(transaction.recipient).to eq(recipient)
    end
  end

  describe 'validations' do
    it 'requires a transaction_type' do
      transaction = Transaction.new(valid_attributes.merge(transaction_type: nil))
      expect(transaction).not_to be_valid
      expect(transaction.errors[:transaction_type]).to include("can't be blank")
    end

    it 'requires a valid transaction_type' do
      transaction = Transaction.new(valid_attributes.merge(transaction_type: 'invalid_type'))
      expect(transaction).not_to be_valid
      expect(transaction.errors[:transaction_type]).to include("is not included in the list")
    end

    it 'requires an amount' do
      transaction = Transaction.new(valid_attributes.merge(amount: nil))
      expect(transaction).not_to be_valid
      expect(transaction.errors[:amount]).to include("can't be blank")
    end

    it 'requires amount to be numeric' do
      transaction = Transaction.new(valid_attributes.merge(amount: 'not_a_number'))
      expect(transaction).not_to be_valid
      expect(transaction.errors[:amount]).to include("is not a number")
    end
  end

  describe 'transaction types' do
    it 'allows deposit transactions' do
      transaction = Transaction.new(valid_attributes.merge(transaction_type: 'deposit'))
      expect(transaction).to be_valid
    end

    it 'allows withdraw transactions' do
      transaction = Transaction.new(valid_attributes.merge(transaction_type: 'withdraw'))
      expect(transaction).to be_valid
    end

    it 'allows transfer transactions' do
      transaction = Transaction.new(valid_attributes.merge(transaction_type: 'transfer'))
      expect(transaction).to be_valid
    end
  end
end
