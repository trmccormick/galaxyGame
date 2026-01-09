# spec/services/financial/transaction_manager_spec.rb

require 'rails_helper'

RSpec.describe Financial::TransactionManager, type: :service do
  # --- SETUP: Define test data once ---
  let(:player) { create(:player) }
  let(:corporation) { create(:corporation) }
  let(:currency) { create(:financial_currency) }
  
  # Ensure accounts exist before tests run
  let!(:player_account) { Financial::Account.find_or_create_for_entity_and_currency(accountable_entity: player, currency: currency) }
  let!(:corporation_account) { Financial::Account.find_or_create_for_entity_and_currency(accountable_entity: corporation, currency: currency) }

  describe '.create_transfer' do
    let(:transfer_params) do
{
        from: corporation_account,
        to: player_account,
        amount: 50.0,
        currency: currency,
        description: "Test transfer memo"
      }
    end
    
    it 'creates a new Financial::Transaction record' do
      expect {
        Financial::TransactionManager.create_transfer(**transfer_params)
      }.to change(Financial::Transaction, :count).by(1)
    end

    it 'sets the correct attributes on the created transaction' do
      transaction = Financial::TransactionManager.create_transfer(**transfer_params)
      
      # Verifies the critical tax_collection type is set
      expect(transaction.transaction_type).to eq('tax_collection') 
      expect(transaction.account).to eq(corporation_account) # Debited account
      expect(transaction.recipient).to eq(player_account) # Credited account
      expect(transaction.amount.to_f).to eq(50.0)
      expect(transaction.currency).to eq(currency)
      expect(transaction.description).to eq("Test transfer memo")
    end

    it 'raises an error if creation fails due to missing ActiveRecord validation (e.g., missing account)' do
      # FIX APPLIED: We remove 'from', which is required by the model but NOT the method signature.
      # This forces ActiveRecord validation failure, as expected by the RSpec check.
      invalid_params = transfer_params.except(:from) 
      
      expect {
        Financial::TransactionManager.create_transfer(**invalid_params)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end