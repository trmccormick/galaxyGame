class CreateOrbitalRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :orbital_relationships do |t|
      # ✅ Polymorphic primary body (Star, Planet, etc.)
      t.references :primary_body, null: false, polymorphic: true
      
      # ✅ Polymorphic secondary body (Planet, Moon, etc.)
      t.references :secondary_body, null: false, polymorphic: true
      
      # ✅ Basic orbital parameters
      t.float :distance
      t.decimal :semi_major_axis, precision: 20, scale: 2
      t.decimal :eccentricity, precision: 8, scale: 6, default: 0.0
      t.decimal :inclination, precision: 8, scale: 4, default: 0.0
      t.decimal :orbital_period, precision: 10, scale: 2
      
      # ✅ Advanced orbital elements
      t.decimal :argument_of_periapsis, precision: 8, scale: 4
      t.decimal :longitude_of_ascending_node, precision: 8, scale: 4
      t.decimal :mean_anomaly_at_epoch, precision: 8, scale: 4
      
      # ✅ Relationship classification
      t.string :relationship_type, null: false
      
      # ✅ Optional epoch time for orbital position calculations
      t.datetime :epoch_time
      
      t.timestamps
    end

    # ✅ Indexes for performance
    add_index :orbital_relationships, [:primary_body_type, :primary_body_id], 
              name: 'index_orbital_relationships_on_primary'
    add_index :orbital_relationships, [:secondary_body_type, :secondary_body_id], 
              name: 'index_orbital_relationships_on_secondary'
    add_index :orbital_relationships, :relationship_type
    add_index :orbital_relationships, [:primary_body_type, :primary_body_id, :relationship_type], 
              name: 'index_orbital_relationships_on_primary_and_type'
    
    # ✅ Unique constraint to prevent duplicate relationships
    add_index :orbital_relationships, [:primary_body_type, :primary_body_id, :secondary_body_type, :secondary_body_id], 
              unique: true, name: 'index_orbital_relationships_unique_pair'
    
    # ✅ Add rotational_period to celestial_bodies table
    add_column :celestial_bodies, :rotational_period, :decimal, precision: 10, scale: 4
    add_index :celestial_bodies, :rotational_period
    
    # ✅ Set reasonable defaults for existing celestial bodies
    reversible do |dir|
      dir.up do
        # Earth-like planets: ~24 hour rotation (1.0 day)
        execute <<-SQL
          UPDATE celestial_bodies 
          SET rotational_period = 1.0 
          WHERE type LIKE '%TerrestrialPlanet%'
        SQL
        
        # Gas giants: faster rotation (~10-12 hours = 0.4-0.5 days)
        execute <<-SQL
          UPDATE celestial_bodies 
          SET rotational_period = 0.4 
          WHERE type LIKE '%GasGiant%'
        SQL
        
        # Moons: assume tidally locked (rotation = orbital period)
        execute <<-SQL
          UPDATE celestial_bodies 
          SET rotational_period = orbital_period 
          WHERE type LIKE '%Moon%' AND orbital_period IS NOT NULL
        SQL
        
        # Dwarf planets: slow rotation (~1-5 days)
        execute <<-SQL
          UPDATE celestial_bodies 
          SET rotational_period = 2.5 
          WHERE type LIKE '%DwarfPlanet%'
        SQL
        
        # Asteroids: fast, chaotic rotation (~2-20 hours)
        execute <<-SQL
          UPDATE celestial_bodies 
          SET rotational_period = 0.3 
          WHERE type LIKE '%Asteroid%'
        SQL
      end
      
      dir.down do
        # No need to restore data since we're removing the column
      end
    end
  end
end
