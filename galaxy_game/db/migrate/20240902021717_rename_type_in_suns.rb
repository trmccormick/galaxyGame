class RenameTypeInSuns < ActiveRecord::Migration[6.1]
  def change
    rename_column :suns, :type, :sun_type
  end
end
