class RenameSunTypeToTypeOfStarInSuns < ActiveRecord::Migration[6.1]
  def change
    rename_column :suns, :sun_type, :type_of_star
  end
end
