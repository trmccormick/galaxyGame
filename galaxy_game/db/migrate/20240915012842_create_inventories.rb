class CreateInventories < ActiveRecord::Migration[7.0]
  def change
    create_table :inventories do |t|
      # Remove the existing colony and base_settlement references
      # and replace them with polymorphic references
      t.references :inventoryable, polymorphic: true, index: true

      # Ensure at least one association is present
      t.check_constraint "(inventoryable_type IS NOT NULL AND inventoryable_id IS NOT NULL)", name: "at_least_one_reference"

      t.timestamps
    end
  end
end