class CreatePlantEnvironments < ActiveRecord::Migration[7.0]
  def change
    create_table :plant_environments do |t|
      t.references :plant, null: false, foreign_key: true
      t.references :environment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
