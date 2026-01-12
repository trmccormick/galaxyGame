class AddFulfilledAtToMarketOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :market_orders, :fulfilled_at, :datetime
  end
end
