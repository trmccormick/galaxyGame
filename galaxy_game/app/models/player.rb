class Player < ApplicationRecord
    include FinancialManagement
    has_many :colonies
    
    # Validations
    validates :name, presence: true
    validates :active_location, presence: true
    
    # Associations
    has_one :inventory, as: :inventoryable, dependent: :destroy
    
    # Methods
    def inventory_at_active_location
      raise ArgumentError, "Player does not have an active location set." if active_location.nil?
      
      # Find the craft or location with this name
      craft = Craft::BaseCraft.find_by(name: active_location)
      return craft.inventory if craft
      
      # If not a craft, look for a location
      location = BaseLocation.find_by(name: active_location)
      return location&.inventory
    end
end