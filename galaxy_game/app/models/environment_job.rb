class EnvironmentJob < ApplicationRecord
  belongs_to :jobable, polymorphic: true
  has_many :material_requests, as: :requestable, dependent: :destroy
  
  validates :job_type, presence: true
  validates :status, presence: true
  
  # Store target values and result data as JSON
  store :target_values, coder: JSON
  store :result_data, coder: JSON
  
  # Job type enum
  enum job_type: {
    pressurization: 0,
    depressurization: 1,
    atmosphere_maintenance: 2,
    temperature_control: 3,
    decontamination: 4
  }
  
  # Status enum
  enum status: {
    scheduled: 0,
    materials_pending: 1,
    in_progress: 2,
    completed: 3,
    failed: 4,
    canceled: 5
  }
  
  # Scopes
  scope :active, -> { where(status: [:scheduled, :materials_pending, :in_progress]) }
  scope :completed, -> { where(status: :completed) }
  scope :failed, -> { where(status: :failed) }
  
  # Methods to check job progress
  def materials_gathered?
    material_requests.all? { |req| req.status == 'fulfilled' }
  end
  
  def estimated_completion_time
    case job_type
    when 'pressurization'
      # Estimate based on volume and current pressure
      environment = jobable
      volume = environment.respond_to?(:volume) ? environment.volume : 0
      current_pressure = environment.atmospheric_data&.pressure || 0
      target_pressure = target_values[:pressure] || GameConstants::STANDARD_PRESSURE_KPA
      
      # Basic formula: larger volumes and bigger pressure differences take longer
      base_time = 1.hour
      volume_factor = [volume / 1000.0, 1.0].max
      pressure_factor = [(target_pressure - current_pressure) / 50.0, 1.0].max
      
      base_time * volume_factor * pressure_factor
    else
      24.hours # Default for other job types
    end
  end
end