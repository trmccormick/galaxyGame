class CreateHydrospheres < ActiveRecord::Migration[7.0]
  def change
    create_table :hydrospheres do |t|
      t.string :liquid_name
      t.float :liquid_volume
      t.float :oceans
      t.float :lakes
      t.float :rivers
      t.float :ice
      t.references :celestial_body, null: false, foreign_key: true

      t.timestamps
    end
  end
end
