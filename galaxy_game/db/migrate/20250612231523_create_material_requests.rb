class CreateMaterialRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :material_requests do |t|
      t.references :requestable, polymorphic: true, null: false, index: true
      t.string :material_name, null: false
      t.decimal :quantity_requested, precision: 10, scale: 2, null: false
      t.decimal :quantity_fulfilled, precision: 10, scale: 2, default: 0
      t.string :status, default: 'pending'
      t.string :priority, default: 'normal'
      t.datetime :fulfilled_at
      
      t.timestamps
    end
    
    add_index :material_requests, [:material_name, :status]
  end
end
