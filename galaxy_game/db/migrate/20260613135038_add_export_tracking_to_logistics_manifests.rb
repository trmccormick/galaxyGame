class AddExportTrackingToLogisticsManifests < ActiveRecord::Migration[7.0]
  def change
    # manifest_type enum: import = 0 (default), export = 1 for return cargo optimization
    add_column :logistics_manifests, :manifest_type, :integer, default: 0, null: false unless column_exists?(:logistics_manifests, :manifest_type)
    
    add_index :logistics_manifests, :manifest_type unless index_exists?(:logistics_manifests, :manifest_type)

    # estimated_revenue_gcc for tracking export revenue projections (precision: 12 digits total, 2 decimal places)
    add_column :logistics_manifests, :estimated_revenue_gcc, :decimal, precision: 12, scale: 2, default: '0.0', null: false unless column_exists?(:logistics_manifests, :estimated_revenue_gcc)

    # total_weight_kg for cargo capacity tracking (used in export optimization algorithms - AstroLift HLT = 50 tons per flight)
    add_column :logistics_manifests, :total_weight_kg, :decimal, precision: 12, scale: 2, default: '0.0', null: false unless column_exists?(:logistics_manifests, :total_weight_kg)
  end
end
