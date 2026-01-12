class AddProgressToMaterialProcessingJobs < ActiveRecord::Migration[7.0]
  def change
    add_column :material_processing_jobs, :progress_hours, :decimal
    add_column :material_processing_jobs, :production_time_hours, :decimal
  end
end
