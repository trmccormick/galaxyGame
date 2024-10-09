class TransactionsController < ApplicationController
    def create
      buyer = Colony.find(params[:buyer_id])
      seller = Colony.find(params[:seller_id])
      amount = params[:amount].to_f
  
      transaction = Transaction.create(buyer: buyer, seller: seller, amount: amount)
  
      if transaction.persisted?
        render json: { message: 'Transaction successful' }, status: :ok
      else
        render json: { errors: transaction.errors.full_messages }, status: :unprocessable_entity
      end
    end
end