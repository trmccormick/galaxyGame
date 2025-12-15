# spec/models/concerns/financial_management_spec.rb
require 'rails_helper'

RSpec.describe FinancialManagement do
  let!(:currency) do
    Financial::Currency.find_by(symbol: 'GCC') || raise("Test requires Financial::Currency with symbol 'GCC' to exist. Please seed the test database appropriately.")
  end
  let(:test_instance) { create(:player) }

  describe 'associations' do
    it 'has an account' do
      expect(test_instance.account).to be_present
      expect(test_instance.account).to be_a(Financial::Account)
    end
  end

  describe '#can_afford?' do
    it 'returns true if account balance is sufficient' do
      test_instance.account.update!(balance: 100)
      expect(test_instance.can_afford?(50)).to be true
    end

    it 'returns false if account balance is insufficient' do
      test_instance.account.update!(balance: 30)
      expect(test_instance.can_afford?(50)).to be false
    end

    it 'handles zero balance' do
      test_instance.account.update!(balance: 0)
      expect(test_instance.can_afford?(1)).to be false
      expect(test_instance.can_afford?(0)).to be true
    end
  end

  describe '#charge' do
    before do
      test_instance.account.update!(balance: 100)
    end

    it 'withdraws money from account' do
      expect {
        test_instance.charge(50, "Test charge")
      }.to change { test_instance.account.reload.balance }.from(100).to(50)
    end

    it 'creates a transaction record' do
      expect {
        test_instance.charge(25, "Test expense")
      }.to change { test_instance.account.transactions.count }.by(1)
      
      transaction = test_instance.account.transactions.last
      expect(transaction.transaction_type).to eq('withdraw')
      expect(transaction.amount).to eq(-25)  # Changed from 25 to -25 (negative for withdrawal)
      expect(transaction.description).to eq("Test expense")
    end

    it 'raises error when no account exists' do
      test_instance.account.destroy
      test_instance.reload
      
      expect {
        test_instance.charge(50)
      }.to raise_error("No account found")
    end
  end

  describe '#credit' do
    before do
      test_instance.account.update!(balance: 100)
    end

    it 'deposits money to account' do
      expect {
        test_instance.credit(50, "Test credit")
      }.to change { test_instance.account.reload.balance }.from(100).to(150)
    end

    it 'creates a transaction record' do
      expect {
        test_instance.credit(75, "Test income")
      }.to change { test_instance.account.transactions.count }.by(1)
      
      transaction = test_instance.account.transactions.last
      expect(transaction.transaction_type).to eq('deposit')  # Check if this is correct
      expect(transaction.amount).to eq(75)
      expect(transaction.description).to eq("Test income")
    end
  end

  describe '#balance' do
    it 'returns account balance' do
      test_instance.account.update!(balance: 123.45)
      expect(test_instance.balance).to eq(123.45)
    end

    it 'returns 0 when no account exists' do
      test_instance.account.destroy
      test_instance.reload
      expect(test_instance.balance).to eq(0)
    end
  end

  describe '#manage_expenses (legacy)' do
    before do
      test_instance.account.update!(balance: 100)
    end

    it 'charges account when funds are sufficient' do
      expect(test_instance.manage_expenses(50, "Legacy expense")).to be true
      expect(test_instance.balance).to eq(50)
    end

    it 'returns false when funds are insufficient' do
      expect(test_instance.manage_expenses(150, "Too expensive")).to be false
      expect(test_instance.balance).to eq(100) # No change
    end
  end

  describe '#update_balance' do
    before do
      test_instance.account.update!(balance: 100)
    end

    it 'credits positive amounts' do
      test_instance.update_balance(50, "Bonus")
      expect(test_instance.balance).to eq(150)
    end

    it 'charges negative amounts' do
      test_instance.update_balance(-30, "Fee")
      expect(test_instance.balance).to eq(70)
    end
  end

  describe 'account creation' do
    it 'creates account after creation with appropriate starting balance and currency' do
      player = create(:player)
      expect(player.account).to be_present
      expect(player.balance).to eq(1_000) # Player starting balance
    end
  end
end
