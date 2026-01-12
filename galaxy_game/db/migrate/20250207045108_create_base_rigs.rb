class CreateBaseRigs < ActiveRecord::Migration[7.0]
  def change
    create_table :base_rigs do |t|
      t.string :identifier, null: false, index: { unique: true }  
      t.string :name
      t.text :description
      t.string :rig_type
      t.integer :capacity
      t.jsonb :operational_data
      t.string :attachable_type
      t.integer :attachable_id

      t.timestamps
    end
  end
end
