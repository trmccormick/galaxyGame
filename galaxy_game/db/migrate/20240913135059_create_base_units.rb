# db/migrate/20240913135059_create_base_units.rb
class CreateBaseUnits < ActiveRecord::Migration[7.0]
  def change
    create_table :base_units do |t|
      t.string :identifier, null: false, index: { unique: true }      
      t.string :name, null: false
      t.string :unit_type, null: false
      t.jsonb :operational_data, default: {}
      
      t.string :location_type
      t.integer :location_id 
      t.references :owner, polymorphic: true, null: false, index: true  
      t.references :attachable, polymorphic: true, index: true
      t.references :base_unit, foreign_key: true, index: true  # Add this line for self-referential relationship

      t.timestamps
    end
  end
end
