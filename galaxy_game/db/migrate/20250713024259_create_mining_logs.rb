class CreateMiningLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :mining_logs do |t|
      t.references :owner, polymorphic: true, null: false
      t.decimal :amount
      t.datetime :mining_timestamp

      t.timestamps
    end
  end
end
