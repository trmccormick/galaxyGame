class CreateEquipmentRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :equipment_requests do |t|
      t.references :requestable, polymorphic: true, null: false, index: true
      t.string :equipment_type, null: false
      t.integer :quantity_requested, null: false
      t.integer :quantity_fulfilled, default: 0
      t.string :status, default: 'pending'
      t.string :priority, default: 'normal'
      t.datetime :fulfilled_at
      
      t.timestamps
    end
    
    add_index :equipment_requests, [:equipment_type, :status]
  end
end
