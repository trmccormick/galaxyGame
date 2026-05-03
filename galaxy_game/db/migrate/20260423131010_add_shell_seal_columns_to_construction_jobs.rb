class AddShellSealColumnsToConstructionJobs < ActiveRecord::Migration[7.0]
  def change
    add_column :construction_jobs, :inflatable_id, :integer
    add_column :construction_jobs, :structure_port_id, :integer
    add_column :construction_jobs, :target_thickness_mm, :decimal
    add_column :construction_jobs, :regolith_source_settlement_id, :integer
  end
end
