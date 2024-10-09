# app/models/storage/solid_storage.rb
module Storage
  class SolidStorage < BaseStorage
    attr_accessor :solid_type

    def initialize(capacity, solid_type)
      super(capacity, 'Solid')                      # Specify type as 'Solid'
      @solid_type = solid_type                      # Store the type of solid
    end

    def transfer_to(other_storage, quantity)
      return "Not enough capacity in destination." unless other_storage.can_add?(quantity)

      if @current_stock >= quantity
        remove_item(solid_type, quantity)          # Remove from current storage
        other_storage.add_item(solid_type, quantity) # Add to other storage
        return "#{quantity} #{solid_type} transferred."
      else
        return "Not enough #{solid_type} available to transfer."
      end
    end

    def can_add?(quantity)
      @current_stock + quantity <= @capacity
    end
  end
end