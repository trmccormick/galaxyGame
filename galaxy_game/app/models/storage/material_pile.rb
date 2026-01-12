module Storage
  class MaterialPile < ApplicationRecord
    belongs_to :surface_storage
    
    validates :material_type, presence: true
    validates :amount, numericality: { greater_than_or_equal_to: 0 }
    validates :quality_factor, numericality: { greater_than: 0, less_than_or_equal_to: 1.0 }

    # Location data for the pile
    attribute :coordinates, :json
    attribute :height, :decimal
    attribute :spread_radius, :decimal
  end
end