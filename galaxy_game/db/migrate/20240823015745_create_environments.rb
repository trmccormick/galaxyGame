class CreateEnvironments < ActiveRecord::Migration[7.0]
  def change
    create_table :environments do |t|
      t.references :biome, null: false, foreign_key: true
      t.references :planet, null: false, foreign_key: true
      t.float :temperature
      t.float :pressure
      t.float :humidity

      t.timestamps
    end
  end
end
