# app/models/inventory.rb
class Inventory < ApplicationRecord
  include Storage # Include the Storage module for capacity checks

  belongs_to :colony

  enum material_type: { raw_material: 0, processed_good: 1 }

  validates :name, presence: true
  validates :material_type, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  def tradeable?
    quantity > 0
  end

  def dynamic_price(buyer_colony)
    trade_service = TradeService.new(self, buyer_colony)
    trade_service.dynamic_price
  end

  def add_quantity(amount)
    if can_store?(amount) # Check if there is enough storage capacity
      self.quantity += amount
      save
    else
      puts "Not enough storage capacity for #{amount}."
    end
  end

  def remove_quantity(amount)
    if quantity >= amount
      self.quantity -= amount
      save
      true
    else
      false # Not enough inventory to remove
    end
  end

  def available?(amount)
    quantity >= amount
  end
end






