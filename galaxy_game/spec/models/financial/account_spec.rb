# spec/models/financial/account_spec.rb
require 'rails_helper'

RSpec.describe Financial::Account, type: :model do
  before(:all) do
    # Global currency setup to prevent "Symbol has already been taken"
    @gcc = Financial::Currency.find_or_create_by!(symbol: 'GCC') do |c|
      c.name = 'Galactic Crypto Currency'
      c.is_system_currency = true
      c.precision = 8
    end
    @usd = Financial::Currency.find_or_create_by!(symbol: 'USD') do |c|
      c.name = 'United States Dollar'
      c.is_system_currency = true
      c.precision = 2
    end
  end

  # Helper to ensure we don't hit unique constraint on (accountable, currency)
  def get_account(owner, currency, balance = 1000)
    acc = Financial::Account.find_or_create_by!(accountable: owner, currency: currency)
    acc.update!(balance: balance)
    acc
  end

  let(:player) { create(:player) }
  let(:recipient_player) { create(:player) }
  let(:player_account) { get_account(player, @gcc, 1000) }
  let(:recipient_account) { get_account(recipient_player, @gcc, 500) }

  describe 'associations' do
    it { should belong_to(:accountable) }
    it { should have_many(:transactions).dependent(:destroy) }
  end

  describe 'validations' do
    # Updated to reflect that negative balances are now allowed for the Ledger logic
    it { should validate_numericality_of(:balance) }
  end

  describe 'Virtual Ledger (Overdraft) Logic' do
    context 'when owner is a Player' do
      it 'strictly prevents negative balances' do
        expect { player_account.withdraw(1500) }.to raise_error("Insufficient funds")
      end
    end

    context 'when owner is a Colony' do
      let(:npc_colony) { build(:colony).tap { |c| c.save!(validate: false) } }
      
      it 'allows the balance to drop below zero (Exodus Oligopoly logic)' do
        acc = get_account(npc_colony, @gcc, 100)
        expect { acc.withdraw(500, "Logistics Debt") }.not_to raise_error
        expect(acc.reload.balance).to eq(-400)
      end
    end
  end

  describe '#deposit' do
    context 'with a valid amount' do
      it 'increases the account balance' do
        expect { player_account.deposit(500, "Test deposit") }
          .to change { player_account.reload.balance }.from(1000).to(1500)

        transaction = player_account.transactions.last
        expect(transaction.amount).to eq(500)
        expect(transaction.transaction_type).to eq("deposit")
      end
    end

    context 'with an invalid amount (negative)' do
      it 'raises an error and does not modify the balance' do
        expect { player_account.deposit(-500) }
          .to raise_error(ArgumentError, "Amount must be positive")
      end
    end
  end

  describe '#withdraw' do
    context 'when funds are sufficient' do
      it 'decreases the account balance' do
        expect { player_account.withdraw(500, "Test withdrawal") }
          .to change { player_account.reload.balance }.from(1000).to(500)
      end
    end

    context 'when funds are insufficient' do
      it 'raises an error for players' do
        expect { player_account.withdraw(2000) }.to raise_error("Insufficient funds")
      end
    end
  end

  describe '#transfer_funds' do
    context 'when funds are sufficient' do
      it 'transfers the amount between accounts' do
        expect { player_account.transfer_funds(500, recipient_account, "Test transfer") }
          .to change { player_account.reload.balance }.to(500)
          .and change { recipient_account.reload.balance }.to(1000)
      end
    end

    context 'when currencies differ' do
      it 'raises a currency mismatch error' do
        usd_acc = get_account(recipient_player, @usd, 100)
        expect { player_account.transfer_funds(10, usd_acc) }
          .to raise_error(/different currencies/)
      end
    end
  end

  describe 'edge cases' do
    it 'prevents withdrawals from zero balance for players' do
      player_account.update!(balance: 0)
      expect { player_account.withdraw(1) }.to raise_error("Insufficient funds")
    end
  end
  
  describe 'different accountable types' do
    it 'works with a player account' do
      expect(player_account.accountable).to be_a(Player)
    end
    
    it 'works with a settlement account' do
      settlement = create(:base_settlement)
      acc = get_account(settlement, @gcc, 100)
      expect(acc.accountable).to be_a(Settlement::BaseSettlement)
    end
    
    it 'works with an organization account' do
      org = create(:organization)
      acc = get_account(org, @gcc, 100)
      expect(acc.accountable).to be_a(Organizations::BaseOrganization)
    end
  end

  describe 'Development Corporation (DC) Trade' do
    let(:dc_builder) {
      create(:organization,
        organization_type: :development_corporation,
        operational_data: { 'is_npc' => true }
      )
    }
    let(:dc_supplier) {
      create(:organization,
        organization_type: :development_corporation,
        operational_data: { 'is_npc' => true }
      )
    }

    let(:consortium_org) {
      create(:organization,
        organization_type: :consortium,
        operational_data: { 'is_npc' => false, 'governance' => { 'voting_model' => 'weighted_by_investment' } }
      )
    }

    it 'allows creation of consortium organization' do
      acc = get_account(consortium_org, @gcc, 100)
      expect(acc.accountable.organization_type).to eq('consortium')
      expect(acc.accountable.operational_data['governance']['voting_model']).to eq('weighted_by_investment')
    end
    
    it 'allows DC-to-DC trade on the virtual ledger via operational_data flags' do
      builder_acc = get_account(dc_builder, @gcc, 0)
      supplier_acc = get_account(dc_supplier, @gcc, 0)

      # This will now pass because is_npc? returns true based on the data field
      expect { 
        builder_acc.transfer_funds(5000, supplier_acc, "Modular Habitation Units") 
      }.not_to raise_error

      expect(builder_acc.reload.balance).to eq(-5000)
      expect(supplier_acc.reload.balance).to eq(5000)
    end
  end
end