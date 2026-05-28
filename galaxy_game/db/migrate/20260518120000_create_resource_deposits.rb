class CreateResourceDeposits < ActiveRecord::Migration[7.0]
  def change
    create_table :resource_deposits do |t|
      t.references :depositable, polymorphic: true, null: false
      t.references :feature, foreign_key: { to_table: :adapted_features }, null: true
      t.references :celestial_location, foreign_key: true, null: true
      t.references :spatial_location, foreign_key: true, null: true
      t.string :material_name, null: false
      t.decimal :initial_mass_kg, precision: 20, scale: 6, null: false
      t.decimal :current_mass_kg, precision: 20, scale: 6, null: false
      t.float :extraction_difficulty
      t.string :depletion_curve
      t.integer :status, null: false, default: 0
      t.jsonb :operational_data, default: {}
      t.timestamps
    end

    # Enforce mutual exclusivity of location columns at the DB level
    execute <<-SQL
      ALTER TABLE resource_deposits
      ADD CONSTRAINT resource_deposits_location_exclusivity
      CHECK (
        ((feature_id IS NOT NULL)::integer + (celestial_location_id IS NOT NULL)::integer + (spatial_location_id IS NOT NULL)::integer) = 1
      );
    SQL
  end
end
