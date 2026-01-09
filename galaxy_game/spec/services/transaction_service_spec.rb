# spec/services/transaction_service_spec.rb
require 'rails_helper'

RSpec.describe TransactionService, type: :service do
  describe '.process_transaction' do
    let(:currency) { create(:currency) }
    let(:buyer) { create(:player) }
    let(:seller) { create(:player) }
    let(:amount) { 1000 }

    context 'when the buyer has sufficient funds' do
      before do
        # Ensure buyer and seller accounts exist and are associated with the correct currency
        buyer_account = buyer.account || create(:financial_account, accountable: buyer, currency: currency)
        seller_account = seller.account || create(:financial_account, accountable: seller, currency: currency)
        buyer_account.update!(balance: 5000, currency: currency)
        seller_account.update!(balance: 0, currency: currency)
      end

      it 'processes the transaction successfully' do
        expect {
          TransactionService.process_transaction(buyer: buyer, seller: seller, amount: amount, currency: currency)
        }.to change { buyer.account.reload.balance }.by(-amount)

        expect(seller.account.reload.balance).to eq(amount)
        expect(Financial::Transaction.count).to eq(2) # Two transactions created - one for each side

        buyer_transaction = Financial::Transaction.find_by(account: buyer.account)
        expect(buyer_transaction.amount).to eq(-amount)
        expect(buyer_transaction.recipient).to eq(seller)
        expect(buyer_transaction.transaction_type).to eq('transfer')

        seller_transaction = Financial::Transaction.find_by(account: seller.account)
        expect(seller_transaction.amount).to eq(amount)
        expect(seller_transaction.recipient).to eq(buyer)
        expect(seller_transaction.transaction_type).to eq('transfer')
      end
    end

    context 'when the buyer has insufficient funds' do
      before do
        buyer_account = buyer.account || create(:financial_account, accountable: buyer, currency: currency)
        seller_account = seller.account || create(:financial_account, accountable: seller, currency: currency)
        buyer_account.update!(balance: 500, currency: currency)
        seller_account.update!(balance: 0, currency: currency)
      end

      it 'raises an error and does not process the transaction' do
        initial_buyer_balance = buyer.account.balance
        initial_seller_balance = seller.account.balance
        initial_transaction_count = Financial::Transaction.count

        expect {
          TransactionService.process_transaction(buyer: buyer, seller: seller, amount: amount, currency: currency)
        }.to raise_error(StandardError, /Insufficient funds/)

        expect(buyer.account.reload.balance).to eq(initial_buyer_balance)
        expect(seller.account.reload.balance).to eq(initial_seller_balance)
        expect(Financial::Transaction.count).to eq(initial_transaction_count)
      end
    end
  end
end

