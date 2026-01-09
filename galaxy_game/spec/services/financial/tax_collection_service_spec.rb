require 'rails_helper'

RSpec.describe Financial::TaxCollectionService, type: :service do
  # Setup entities and accounts
  let(:corporation) { create(:corporation, tax_rate: 0.15) } # Corporation has 15% rate
  let(:currency) { create(:financial_currency) }
  let(:sale_price) { 1000.0 }
  let(:expected_tax_amount) { sale_price * 0.15 } # 150.0
  
  # Ensure accounts exist for the seller and the authority
  let!(:corporation_account) { Financial::Account.find_or_create_for_entity_and_currency(accountable_entity: corporation, currency: currency) }
  let!(:tax_authority_account) { 
    authority = Organizations::TaxAuthority.instance
    Financial::Account.find_or_create_for_entity_and_currency(accountable_entity: authority, currency: currency)
  }

  describe '.collect_sales_tax' do
    # Spy on the TransactionManager to ensure the transfer is requested correctly
    before do
      # We mock the manager to ensure we only test the tax service's logic, not the manager's persistence.
      allow(Financial::TransactionManager).to receive(:create_transfer).and_return(double('Transaction', persisted?: true, id: 'mock-txn-1'))
    end
    
    context 'when tax is applicable' do
      it 'calculates the correct tax amount' do
        tax_result = Financial::TaxCollectionService.collect_sales_tax(corporation, sale_price, currency)
        expect(tax_result[:tax_paid]).to eq(expected_tax_amount)
        expect(tax_result[:success]).to be true
      end

      it 'calls the TransactionManager to move the tax funds' do
        Financial::TaxCollectionService.collect_sales_tax(corporation, sale_price, currency)

        # Verify that the correct transfer was requested
        expect(Financial::TransactionManager).to have_received(:create_transfer).with(
          hash_including(
            from: corporation_account,
            to: tax_authority_account,
            amount: expected_tax_amount,
            currency: currency,
            description: "GCC Operational Tax on $1000.00 sale."
          )
        )
      end
    end
    
    context 'when tax rate is zero (e.g., for Tax Authority)' do
      let(:authority) { Organizations::TaxAuthority.instance }
      
      it 'returns 0.0 and does not call the TransactionManager' do
        # TaxAuthority's `tax_rate` is 0.0
        tax_result = Financial::TaxCollectionService.collect_sales_tax(authority, sale_price, currency)
        
        expect(tax_result[:tax_paid]).to eq(0.0)
        expect(tax_result[:success]).to be true
        expect(Financial::TransactionManager).not_to have_received(:create_transfer)
      end
    end
    
    context 'when organization is missing a tax rate' do
      let(:missing_rate_entity) { create(:player) } # Assuming Player doesn't define a tax_rate method
      
      it 'returns 0.0 and does not call the TransactionManager' do
        tax_result = Financial::TaxCollectionService.collect_sales_tax(missing_rate_entity, sale_price, currency)
        
        expect(tax_result[:tax_paid]).to eq(0.0)
        expect(tax_result[:success]).to be true
        expect(Financial::TransactionManager).not_to have_received(:create_transfer)
      end
    end
  end
end