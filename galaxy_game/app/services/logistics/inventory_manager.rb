# --- app/services/logistics/inventory_manager.rb (FIXED for Polymorphism) ---
module Logistics
  class InventoryManager
    # Handles the transfer of items between inventories
    def self.transfer_item(item_name:, quantity:, from_inventory:, to_inventory:)
      
      # Check if destination is a station with orbital construction projects
      if to_inventory.inventoryable.is_a?(Settlement::BaseSettlement) && 
         to_inventory.inventoryable.orbital? && 
         should_check_orbital_projects?(item_name)
        
        # Try to deliver to orbital construction projects first
        remaining_quantity = Construction::OrbitalShipyardService.deliver_materials(
          to_inventory.inventoryable, 
          item_name, 
          quantity, 
          from_inventory.inventoryable.is_a?(Settlement::BaseSettlement) ? from_inventory.inventoryable : nil
        )
        
        # Only transfer remaining quantity to station inventory
        quantity = remaining_quantity
        return true if quantity <= 0 # All consumed by projects
      end
      
      # 1. DEDUCT from the seller's inventory (Source: Player OR NPC Settlement)
      # Find the specific Item instance the seller is offering
      seller_item = from_inventory.items.find_by!(name: item_name)
      
      # Check if the seller has enough quantity *before* updating
      if seller_item.amount < quantity
         raise "Trade failed: Seller (ID: #{from_inventory.inventoryable_id}) inventory shortfall for #{item_name}."
      end
      
      seller_item.amount -= quantity
      seller_item.save!
      
      # 2. ADD to the buyer's inventory (Destination: NPC Settlement or Player)
      # Find or initialize the item instance in the buyer's inventory
      buyer_item = to_inventory.items.find_or_initialize_by(name: item_name) do |item|
        # Set required attributes for new items
        item.owner = to_inventory.inventoryable
        item.inventory = to_inventory
        item.material_type = seller_item.material_type
        item.storage_method = seller_item.storage_method
        item.metadata = seller_item.metadata || {}
        item.durability = seller_item.durability
      end
      buyer_item.amount ||= 0 # Initialize amount if new
      buyer_item.amount += quantity
      buyer_item.save!

      true
    rescue ActiveRecord::RecordNotFound
      # The failure is now more descriptive of the entity
      raise "Trade failed: Item '#{item_name}' not found in source inventory (ID: #{from_inventory.inventoryable_id})."
    end
    
    private
    
    def self.should_check_orbital_projects?(item_name)
      # Check if this material is used in orbital construction
      orbital_materials = ['modular_structural_panel_base', 'ibeam', 'structural_panel', 'support_beam']
      orbital_materials.include?(item_name) || item_name.include?('panel') || item_name.include?('beam')
    end
  end
end