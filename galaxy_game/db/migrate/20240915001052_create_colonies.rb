class CreateColonies < ActiveRecord::Migration[7.0]
  def change
    create_table :colonies do |t|
      t.string :name
      t.integer :capacity
      t.references :celestial_body, null: false, foreign_key: true

      t.timestamps
    end
  end
end
