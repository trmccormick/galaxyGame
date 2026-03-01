class MakeDockedAtPolymorphic < ActiveRecord::Migration[7.0]
  def up
    # Remove old foreign key constraint if it exists
    if foreign_key_exists?(:base_crafts, :base_settlements, column: :docked_at_id)
      remove_foreign_key :base_crafts, :base_settlements, column: :docked_at_id
    end

    # Add docked_at_type for polymorphic association
    add_column :base_crafts, :docked_at_type, :string

    # Add composite index for performance
    add_index :base_crafts, [:docked_at_type, :docked_at_id]
  end

  def down
    remove_index :base_crafts, [:docked_at_type, :docked_at_id]
    remove_column :base_crafts, :docked_at_type
    # Re-add the foreign key constraint (assumes original state)
    add_foreign_key :base_crafts, :base_settlements, column: :docked_at_id
  end
end
