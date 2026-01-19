class AddLicensedRunsToBlueprints < ActiveRecord::Migration[7.0]
  def change
    add_column :blueprints, :licensed_runs_remaining, :integer
  end
end