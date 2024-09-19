class CreateGases < ActiveRecord::Migration[7.0]
  def change
    create_table :gases do |t|
      t.string :name
      t.float :percentage
      t.float :ppm
      t.references :celestial_body, null: false, foreign_key: true

      t.timestamps
    end
  end

  def down
    drop_table :gases
  end
end
