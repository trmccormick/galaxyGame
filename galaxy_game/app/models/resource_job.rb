class ResourceJob < ApplicationRecord
  belongs_to :settlement
  belongs_to :location, optional: true
  
  # Job data as JSON
  store :job_data, coder: JSON
  
  # Enums
  enum job_type: {
    harvesting: 0,
    processing: 1,
    manufacturing: 2,
    recycling: 3
  }
  
  enum status: {
    scheduled: 0,
    in_progress: 1,
    completed: 2,
    failed: 3,
    canceled: 4
  }
  
  # Scopes
  scope :active, -> { where(status: [:scheduled, :in_progress]) }
  scope :pending_completion, -> { where(status: :in_progress).where('estimated_completion <= ?', Time.current) }
  
  # Virtual attribute for assigned units
  def assigned_units=(unit_ids)
    self.job_data ||= {}
    self.job_data['assigned_unit_ids'] = unit_ids
  end
  
  def assigned_units
    (self.job_data || {})['assigned_unit_ids'] || []
  end
  
  # Convenience methods
  def progress_percentage
    return 100 if completed?
    return 0 if scheduled?
    
    # Calculate based on time
    start_time = created_at
    end_time = estimated_completion
    current_time = Time.current
    
    return 50 unless end_time # Default if no estimated completion
    
    total_duration = end_time - start_time
    elapsed = current_time - start_time
    
    progress = (elapsed / total_duration * 100).round
    [progress, 99].min # Cap at 99% until formally completed
  end
end