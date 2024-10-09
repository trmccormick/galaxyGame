class Computer < ApplicationRecord
    belongs_to :colony
  
    def mine
      mining_power
    end
end