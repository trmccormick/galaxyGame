class CreateSolarSystems < ActiveRecord::Migration[6.1]
  def change
    create_table :solar_systems do |t|
      t.string :name, null: false
      t.references :current_star, foreign_key: { to_table: :stars }, optional: true

      t.timestamps
    end
  end
end