class TradesController < ApplicationController
    def create
      buyer = Colony.find(params[:buyer_id])
      seller = Colony.find(params[:seller_id])
      resource = Resource.find(params[:resource_id])
      amount = params[:amount]
      price = params[:price]
  
      transaction = Transaction.create(buyer: buyer, seller: seller, resource: resource, amount: amount, price: price)
  
      if transaction.persisted?
        render json: { message: 'Trade successful' }, status: :ok
      else
        render json: { error: transaction.errors.full_messages }, status: :unprocessable_entity
      end
    end
end