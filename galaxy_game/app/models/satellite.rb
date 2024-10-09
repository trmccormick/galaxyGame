class Satellite < ApplicationRecord
    belongs_to :colony
  
    validates :mining_output, numericality: { greater_than_or_equal_to: 0 }
  
    # Mining function, output is in GCC
    def mine
      mining_output
    end
end