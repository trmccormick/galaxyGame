class CreateStructuresPlanetaryUmbilicalHubs < ActiveRecord::Migration[7.0]
  def change
    create_table :structures_planetary_umbilical_hubs do |t|
      t.references :settlement, null: false, foreign_key: { to_table: :base_settlements }
      t.string :name

      t.timestamps
    end
  end
end
