class RemoveAtmosphereFromPlanets < ActiveRecord::Migration[7.0]
  def change
    remove_column :planets, :atmosphere, :jsonb
  end
end
