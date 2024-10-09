class CreateDomes < ActiveRecord::Migration[7.0]
  def change
    create_table :domes do |t|
      t.string :name
      t.integer :capacity
      t.references :settlement, null: false, foreign_key: true

      t.timestamps
    end
  end
end
