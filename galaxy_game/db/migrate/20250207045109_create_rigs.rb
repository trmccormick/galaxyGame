class CreateRigs < ActiveRecord::Migration[7.0]
  def change
    create_table :rigs do |t|
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
