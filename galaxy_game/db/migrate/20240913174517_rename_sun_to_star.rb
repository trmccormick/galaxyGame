class RenameSunToStar < ActiveRecord::Migration[6.0]
  def change
    rename_table :suns, :stars
  end
end
