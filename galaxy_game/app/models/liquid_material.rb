class LiquidMaterial < ApplicationRecord
  belongs_to :hydrosphere

  # Add attributes for the material's name, amount, and state (liquid/solid)
  validates :name, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
end

