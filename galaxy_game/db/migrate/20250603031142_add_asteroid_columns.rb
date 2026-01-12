class AddAsteroidColumns < ActiveRecord::Migration[7.0]
  def change
    # Add the origin_body_id column to celestial_bodies if it doesn't exist
    add_column :celestial_bodies, :origin_body_id, :integer unless column_exists?(:celestial_bodies, :origin_body_id)
    add_index :celestial_bodies, :origin_body_id unless index_exists?(:celestial_bodies, :origin_body_id)
    
    # Add a composition_type column if it doesn't exist
    add_column :celestial_bodies, :composition_type, :string unless column_exists?(:celestial_bodies, :composition_type)
  end
end