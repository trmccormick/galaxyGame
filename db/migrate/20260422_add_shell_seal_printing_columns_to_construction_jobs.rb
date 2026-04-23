class AddShellSealPrintingColumnsToConstructionJobs < ActiveRecord::Migration[7.0]
  def change
    add_column :construction_jobs, :inflatable_id, :integer
    add_column :construction_jobs, :structure_port_id, :integer
    add_column :construction_jobs, :target_thickness_mm, :decimal, precision: 8, scale: 2
    add_column :construction_jobs, :regolith_source_settlement_id, :integer

    add_index :construction_jobs, :inflatable_id
    add_index :construction_jobs, :structure_port_id
    add_index :construction_jobs, :regolith_source_settlement_id
  end
end
