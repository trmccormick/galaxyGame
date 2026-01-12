# db/migrate/20251221151904_add_covering_attributes_to_worldhouse_segments.rb
class AddCoveringAttributesToWorldhouseSegments < ActiveRecord::Migration[7.0]
  def change
    add_column :worldhouse_segments, :cover_status, :string, default: 'uncovered'
    add_column :worldhouse_segments, :panel_type, :string
    add_column :worldhouse_segments, :construction_date, :datetime
    add_column :worldhouse_segments, :estimated_completion, :datetime
    
    # Also add operational_data if it doesn't exist
    unless column_exists?(:worldhouse_segments, :operational_data)
      add_column :worldhouse_segments, :operational_data, :jsonb, default: {}
    end
  end
end