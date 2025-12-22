# db/migrate/20251222022729_add_altitude_to_celestial_locations.rb
class AddAltitudeToCelestialLocations < ActiveRecord::Migration[7.0]
  def change
    # Simply add altitude to existing table structure
    add_column :celestial_locations, :altitude, :decimal, precision: 15, scale: 2
    
    # Add index for orbital queries
    add_index :celestial_locations, :altitude
    
    # Add check constraint to ensure altitude makes sense
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE celestial_locations
          ADD CONSTRAINT check_altitude_non_negative
          CHECK (altitude IS NULL OR altitude >= 0);
        SQL
      end
      
      dir.down do
        execute <<-SQL
          ALTER TABLE celestial_locations
          DROP CONSTRAINT check_altitude_non_negative;
        SQL
      end
    end
  end
end