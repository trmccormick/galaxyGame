require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  let(:buyer) { create(:player) }
  let(:seller) { create(:corporation) }
  let(:currency) { create(:financial_currency) }

  # Ensure accounts exist so we can check the final transaction relationships
  let!(:buyer_account) { Financial::Account.find_or_create_for_entity_and_currency(accountable_entity: buyer, currency: currency) }
  let!(:seller_account) { Financial::Account.find_or_create_for_entity_and_currency(accountable_entity: seller, currency: currency) }

  # Create a mock/spy for the service we want to ensure is NOT called by the controller
  before do
    # Assuming Financial::TaxCollectionService is defined (or will be shortly)
    # We allow it to exist but expect it to not be called in the controller context.
    allow(Financial::TaxCollectionService).to receive(:collect_sales_tax).and_return({ success: true, tax_paid: 0.0, transaction_id: nil, error: nil }) 
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          buyer_type: buyer.class.name,
          buyer_id: buyer.id,
          seller_type: seller.class.name,
          seller_id: seller.id,
          currency_id: currency.id,
          amount: 100.0
        }
      end

      it 'creates a new financial transaction' do
        expect {
          post :create, params: valid_params
        }.to change(Financial::Transaction, :count).by(1)
      end
      
      it 'creates the transaction with correct account information and amount' do
        post :create, params: valid_params
        
        transaction = Financial::Transaction.last
        
        # Verify transaction integrity
        expect(transaction.account).to eq(buyer_account) # Buyer's account is the source (debited)
        expect(transaction.recipient).to eq(seller_account) # Seller's account is the destination (credited)
        expect(transaction.amount.to_f).to eq(100.0)
        expect(transaction.transaction_type).to eq('transfer')
      end

      it 'does not attempt to collect tax (enforces separation of concerns)' do
        # This is the critical architectural check: the controller should not handle business logic.
        expect(Financial::TaxCollectionService).to_not receive(:collect_sales_tax)
        
        post :create, params: valid_params
      end

      it 'returns a success message' do
        post :create, params: valid_params
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to include('Transaction successful')
      end
    end

    context 'with invalid parameters' do
      # ... (existing invalid tests, cleaned up for completeness) ...

      it 'does not create a transaction if amount is missing' do
        expect {
          post :create, params: {
            buyer_type: buyer.class.name,
            buyer_id: buyer.id,
            seller_type: seller.class.name,
            seller_id: seller.id,
            currency_id: currency.id
            # amount missing
          }
        }.to_not change(Financial::Transaction, :count)
      end

      it 'returns an error message if amount is missing or invalid' do
        post :create, params: {
          buyer_type: buyer.class.name,
          buyer_id: buyer.id,
          seller_type: seller.class.name,
          seller_id: seller.id,
          currency_id: currency.id,
          amount: 0.0 # Invalid amount
        }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to be_present
      end
    end
  end
end