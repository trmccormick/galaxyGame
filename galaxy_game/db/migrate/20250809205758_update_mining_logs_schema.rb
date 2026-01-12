# Create this migration: bin/rails generate migration UpdateMiningLogsSchema
class UpdateMiningLogsSchema < ActiveRecord::Migration[7.0]
  def change
    # Add missing columns
    add_column :mining_logs, :currency, :string, default: 'GCC'
    add_column :mining_logs, :operational_details, :json, default: {}
    add_column :mining_logs, :job_metadata, :json, default: {}
    
    # Rename columns to match code expectations
    rename_column :mining_logs, :amount, :amount_mined
    rename_column :mining_logs, :mining_timestamp, :mined_at
    
    # Add indexes for better performance
    add_index :mining_logs, [:owner_type, :owner_id]
    add_index :mining_logs, :mined_at
    add_index :mining_logs, :currency
  end
end
