class AddGasGiantAttributes < ActiveRecord::Migration[6.1]
  def change
    add_column :celestial_bodies, :hydrogen_concentration, :float
    add_column :celestial_bodies, :helium_concentration, :float
  end
end
