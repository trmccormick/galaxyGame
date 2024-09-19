class CreateResources < ActiveRecord::Migration[7.0]
  def change
    create_table :resources do |t|
      t.references :colony, foreign_key: true
      # t.references :planet, foreign_key: true
      t.string :name
      t.integer :quantity
      t.timestamps
    end
  end
end
