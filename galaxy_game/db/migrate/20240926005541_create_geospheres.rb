class CreateGeospheres < ActiveRecord::Migration[7.0]
  def change
    create_table :geospheres do |t|
      t.references :celestial_body, null: false, foreign_key: true
      t.json :crust, default: {}    # Storing crust composition as a JSON object
      t.json :mantle, default: {}   # Storing mantle properties as a JSON object
      t.json :core, default: {}     # Storing core properties as a JSON object
      t.json :resources, default: {} # Resources extracted from geosphere
      t.float :temperature, default: 0.0 # Temperature of the geosphere
      t.float :pressure, default: 0.0    # Pressure of the geosphere

      t.timestamps
    end
  end
end

