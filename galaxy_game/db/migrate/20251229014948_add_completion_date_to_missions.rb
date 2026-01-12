class AddCompletionDateToMissions < ActiveRecord::Migration[7.0]
  def change
    add_column :missions, :completion_date, :datetime
  end
end
