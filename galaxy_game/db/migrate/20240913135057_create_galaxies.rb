# db/migrate/20240913135057_create_galaxies.rb
class CreateGalaxies < ActiveRecord::Migration[7.0]
  def change
    create_table :galaxies do |t|
      # Basic attributes
      t.string :name
      t.string :identifier, null: false
      t.decimal :mass, precision: 20, scale: 2
      t.decimal :diameter, precision: 20, scale: 2
      t.string :galaxy_type
      t.integer :age_in_billions
      t.integer :star_count

      t.timestamps
    end

    add_index :galaxies, :identifier, unique: true
    add_index :galaxies, :name
    add_index :galaxies, :galaxy_type
  end
end

