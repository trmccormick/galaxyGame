# app/models/storage/base_storage.rb
module Storage
  class BaseStorage
    include Storage

    attr_accessor :current_stock, :item_type, :inventory

    def initialize(capacity, item_type)
      initialize_storage(capacity)  # Initialize storage capacity
      @current_stock = 0
      @item_type = item_type
      @inventory = Inventory.new     # Create an Inventory for this storage unit
    end

    def add_item(item, quantity)
      if can_store?(quantity)          # Check if we can store the item
        @inventory.add_item(item)      # Add item to inventory
        @current_stock += quantity       # Update current stock
        return "#{quantity} #{item.name} added to storage."
      else
        return "Not enough capacity to add #{quantity} #{item.name}."
      end
    end

    def remove_item(name, quantity)
      item = @inventory.find_item(name)
      return "Item not found." unless item

      if item.quantity >= quantity
        item.quantity -= quantity         # Reduce item quantity
        @current_stock -= quantity         # Update current stock
        return "#{quantity} #{item.name} removed from storage."
      else
        return "Not enough #{item.name} available."
      end
    end
  end
end


  