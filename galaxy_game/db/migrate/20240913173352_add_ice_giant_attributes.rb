class AddIceGiantAttributes < ActiveRecord::Migration[6.1]
  def change
    add_column :celestial_bodies, :methane_concentration, :float
    add_column :celestial_bodies, :ammonia_concentration, :float
  end
end
