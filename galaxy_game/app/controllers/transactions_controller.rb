class TransactionsController < ApplicationController
  def create
    buyer = find_transactable(params[:buyer_type], params[:buyer_id])
    seller = find_transactable(params[:seller_type], params[:seller_id])
    amount = params[:amount].to_f
    currency = Financial::Currency.find(params[:currency_id])

    # Create financial transaction
    transaction = Financial::Transaction.create(
      account: buyer_account(buyer, currency),
      recipient: seller_account(seller, currency),
      amount: amount,
      currency: currency,
      transaction_type: 'transfer'
    )

    if transaction.persisted?
      render json: { message: 'Transaction successful' }, status: :ok
    else
      render json: { errors: transaction.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def find_transactable(type, id)
    type.constantize.find(id)
  rescue NameError
    nil
  end

  def buyer_account(buyer, currency)
    # Find or create account for the buyer
    Financial::Account.find_or_create_for_entity_and_currency(
      accountable_entity: buyer,
      currency: currency
    )
  end

  def seller_account(seller, currency)
    # Find or create account for the seller
    Financial::Account.find_or_create_for_entity_and_currency(
      accountable_entity: seller,
      currency: currency
    )
  end
end