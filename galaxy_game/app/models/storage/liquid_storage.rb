# app/models/storage/liquid_storage.rb
module Storage
  class LiquidStorage < BaseStorage
    attr_accessor :liquid_type

    def initialize(capacity, liquid_type)
      super(capacity, 'Liquid')                     # Specify type as 'Liquid'
      @liquid_type = liquid_type                     # Store the type of liquid
    end

    def transfer_to(other_storage, quantity)
      return "Not enough capacity in destination." unless other_storage.can_add?(quantity)

      if @current_stock >= quantity
        remove_item(liquid_type, quantity)          # Remove from current storage
        other_storage.add_item(liquid_type, quantity) # Add to other storage
        return "#{quantity} #{liquid_type} transferred."
      else
        return "Not enough #{liquid_type} available to transfer."
      end
    end

    def can_add?(quantity)
      @current_stock + quantity <= @capacity
    end
  end
end
  