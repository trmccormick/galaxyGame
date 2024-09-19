class RenameDistanceFromSunToDistanceFromStar < ActiveRecord::Migration[6.1]
  def change
    rename_column :celestial_bodies, :distance_from_sun, :distance_from_star
  end
end

