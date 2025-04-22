class CreateWormholes < ActiveRecord::Migration[7.0]
  def change
    create_table :wormholes do |t|
      t.references :solar_system_a, null: false, foreign_key: { to_table: :solar_systems }
      t.references :solar_system_b, null: false, foreign_key: { to_table: :solar_systems }
      t.integer :wormhole_type, null: false, default: 0
      t.integer :stability, default: 0
      t.integer :disruption_level, default: 0
      t.datetime :formation_date
      t.float :decay_rate
      t.integer :power_requirement
      t.decimal :mass_limit, precision: 20, scale: 2, default: 0
      t.decimal :mass_transferred_a, precision: 20, scale: 2, default: 0  # Mass through point A
      t.decimal :mass_transferred_b, precision: 20, scale: 2, default: 0  # Mass through point B
      t.boolean :point_a_stabilized, default: false
      t.boolean :point_b_stabilized, default: false
      t.boolean :hazard_zone, default: false
      t.boolean :exotic_resources, default: false
      t.boolean :traversed, default: false
      t.boolean :natural, default: true, null: false

      t.timestamps
    end
    
    # Make sure spatial_locations table has locationable columns if they don't exist
    unless column_exists?(:spatial_locations, :locationable_type)
      add_reference :spatial_locations, :locationable, polymorphic: true, index: true
    end
  end
end
