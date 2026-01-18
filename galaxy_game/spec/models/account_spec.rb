require 'rails_helper'

RSpec.describe Financial::Account, type: :model do
  # Create players with accounts
  let(:player) { create(:player) }
  let(:recipient_player) { create(:player) }

  # Create accounts explicitly
  let(:player_account) { create(:account, accountable: player, balance: 1_000) }
  let(:recipient_account) { create(:account, accountable: recipient_player, balance: 500) }

  describe 'associations' do
    it { should belong_to(:accountable) }
    it { should have_many(:transactions).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:balance).is_greater_than_or_equal_to(0) }
  end

  describe '#deposit' do
    context 'with a valid amount' do
      it 'increases the account balance' do
        expect { player_account.deposit(500, "Test deposit") }
          .to change { player_account.reload.balance }.from(1_000).to(1_500)

        # Verify the transaction log
        transaction = player_account.transactions.last
        expect(transaction.amount).to eq(500)
        expect(transaction.transaction_type).to eq("deposit")
        expect(transaction.description).to eq("Test deposit")
        expect(transaction.recipient).to eq(player) # recipient is the player
      end
    end

    context 'with an invalid amount (negative)' do
      it 'raises an error and does not modify the balance' do
        expect { player_account.deposit(-500, "Invalid deposit") }
          .to raise_error(ArgumentError, "Amount must be positive")

        expect(player_account.reload.balance).to eq(1_000)
      end
    end
  end

  describe '#withdraw' do
    context 'when funds are sufficient' do
      it 'decreases the account balance' do
        expect { player_account.withdraw(500, "Test withdrawal") }
          .to change { player_account.reload.balance }.from(1_000).to(500)

        # Verify the transaction log
        transaction = player_account.transactions.last
        expect(transaction.amount).to eq(-500)
        expect(transaction.transaction_type).to eq("withdraw")
        expect(transaction.description).to eq("Test withdrawal")
        expect(transaction.recipient).to eq(player) # recipient is the player
      end
    end

    context 'when funds are insufficient' do
      it 'raises an error and does not modify the balance' do
        expect { player_account.withdraw(2_000, "Overdraft attempt") }
          .to raise_error("Insufficient funds")

        expect(player_account.reload.balance).to eq(1_000)
      end
    end
  end

  describe '#transfer_funds' do
    context 'when funds are sufficient' do
      it 'transfers the amount from one account to another' do
        expect { player_account.transfer_funds(500, recipient_account, "Test transfer") }
          .to change { player_account.reload.balance }.from(1_000).to(500)
          .and change { recipient_account.reload.balance }.from(500).to(1_000)

        # Verify transactions for both accounts
        sender_transaction = player_account.transactions.last
        recipient_transaction = recipient_account.transactions.last

        expect(sender_transaction.amount).to eq(-500)
        expect(sender_transaction.transaction_type).to eq("transfer")
        expect(sender_transaction.description).to eq("Test transfer")
        expect(sender_transaction.recipient).to eq(recipient_player) # recipient is the player

        expect(recipient_transaction.amount).to eq(500)
        expect(recipient_transaction.transaction_type).to eq("transfer")
        expect(recipient_transaction.description).to eq("Test transfer")
        expect(recipient_transaction.recipient).to eq(player) # recipient is the player
      end
    end

    context 'when funds are insufficient' do
      it 'raises an error and does not modify balances' do
        expect { player_account.transfer_funds(2_000, recipient_account, "Overdraft transfer attempt") }
          .to raise_error("Insufficient funds")

        expect(player_account.reload.balance).to eq(1_000)
        expect(recipient_account.reload.balance).to eq(500)
      end
    end
  end

  describe 'edge cases' do
    context 'when balance is exactly zero' do
      before do
        player_account.update!(balance: 0)
      end

      it 'prevents withdrawals or transfers' do
        expect { player_account.withdraw(1, "Withdrawal from zero balance") }
          .to raise_error("Insufficient funds")

        expect { player_account.transfer_funds(1, recipient_account, "Transfer from zero balance") }
          .to raise_error("Insufficient funds")
      end

      it 'allows deposits' do
        expect { player_account.deposit(1_000, "Deposit to zero balance") }
          .to change { player_account.reload.balance }.from(0).to(1_000)
      end
    end
  end
  
  describe 'different accountable types' do
    it 'works with a player account' do
      account = create(:account, accountable: create(:player))
      expect(account.accountable).to be_a(Player)
    end
    
    it 'works with a settlement account' do
      account = create(:account, accountable: create(:base_settlement))
      expect(account.accountable).to be_a(Settlement::BaseSettlement)
    end
    
    it 'works with an organization account' do
      account = create(:account, accountable: create(:organization))
      expect(account.accountable).to be_a(Organizations::BaseOrganization)
    end
    
    # it 'works with a colony account' do
    #   # Create a colony with validation disabled
    #   colony = build(:colony)
    #   colony.define_singleton_method(:must_have_multiple_settlements) { true }
    #   colony.save!
      
    #   account = create(:account, accountable: colony)
    #   expect(account.accountable).to be_a(Colony)
    # end
  end
end
