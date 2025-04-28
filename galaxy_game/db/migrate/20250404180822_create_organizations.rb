class CreateOrganizations < ActiveRecord::Migration[7.0]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :identifier, null: false, index: { unique: true }
      t.integer :organization_type, null: false, default: 0
      t.json :operational_data
      t.string :description
      t.references :owner, polymorphic: true, null: true
      
      t.timestamps
    end
  end
end
