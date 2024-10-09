class CreateAtmospheres < ActiveRecord::Migration[7.0]
  def change
    create_table :atmospheres do |t|
      t.references :celestial_body, null: false, foreign_key: true
      t.float :temperature, default: 0
      t.float :pressure, default: 0
      t.json :atmosphere_composition, default: {}
      t.float :total_atmospheric_mass, default: 0
      t.json :dust, default: {}
      t.integer :pollution, default: 0      

      t.timestamps
    end
  end
end