# db/migrate/20240913135056_create_base_locations.rb
class CreateBaseLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :base_locations do |t|
      t.string :name, null: false
      t.references :locationable, polymorphic: true

      t.timestamps
    end

    add_index :base_locations, :name
  end
end

