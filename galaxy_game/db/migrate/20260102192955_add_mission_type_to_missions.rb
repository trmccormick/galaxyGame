class AddMissionTypeToMissions < ActiveRecord::Migration[7.0]
  def change
    add_column :missions, :mission_type, :string
  end
end
