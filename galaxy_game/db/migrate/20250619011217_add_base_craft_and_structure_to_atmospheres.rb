class AddBaseCraftAndStructureToAtmospheres < ActiveRecord::Migration[7.0]
  def change
    # Add craft reference
    add_reference :atmospheres, :craft, null: true, foreign_key: { to_table: :base_crafts }
    
    # Add structure reference  
    add_reference :atmospheres, :structure, null: true, foreign_key: { to_table: :structures }
    
    # Make celestial_body optional since atmospheres can now belong to craft/structures
    change_column_null :atmospheres, :celestial_body_id, true
  end
end
