class CreateOrbitalRelationships < ActiveRecord::Migration[6.1]
  def change
    create_table :orbital_relationships do |t|
      t.references :celestial_body, null: false, foreign_key: true
      t.integer :sun_id, null: false
      t.float :distance

      t.timestamps
    end

    add_index :orbital_relationships, :sun_id
  end
end
