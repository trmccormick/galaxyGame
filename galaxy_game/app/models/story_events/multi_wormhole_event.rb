# MultiWormholeEvent model for tracking AI Manager story events
class MultiWormholeEvent < ApplicationRecord
  belongs_to :trigger_system, class_name: 'SolarSystem', optional: true
  belongs_to :system_a, class_name: 'SolarSystem', optional: true
  belongs_to :system_b, class_name: 'SolarSystem', optional: true

  validates :event_status, presence: true
  validates :stability_window_hours, presence: true, numericality: { greater_than: 0 }

  enum event_status: { triggered: 0, assessing: 1, deciding: 2, executing: 3, completed: 4, failed: 5 }

  scope :active, -> { where(event_status: [:triggered, :assessing, :deciding, :executing]) }
  scope :completed_successfully, -> { where(event_status: :completed) }

  # JSON fields for complex data storage
  serialize :system_assessments, JSON
  serialize :strategic_decisions, JSON
  serialize :stabilization_results, JSON
  serialize :learning_patterns, JSON
  serialize :event_characteristics, JSON

  def self.trigger_event(trigger_system, system_a, system_b, event_characteristics = {})
    create!(
      trigger_system: trigger_system,
      system_a: system_a,
      system_b: system_b,
      event_status: :triggered,
      stability_window_hours: calculate_stability_window(event_characteristics),
      event_characteristics: event_characteristics,
      triggered_at: Time.current
    )
  end

  def self.calculate_stability_window(characteristics)
    base_hours = 48 # 48 hours base

    # Counterbalance quality affects stability
    counterbalance_quality = characteristics[:counterbalance_quality] || 1.0
    stabilization_efforts = characteristics[:stabilization_efforts] || 0

    # Variable stability: 24-72 hours
    multiplier = counterbalance_quality + (stabilization_efforts * 0.1)
    multiplier = [0.5, [multiplier, 1.5].min].max

    (base_hours * multiplier).to_i
  end

  def stability_remaining_hours
    return 0 if completed? || failed?

    elapsed_hours = (Time.current - triggered_at) / 1.hour
    [stability_window_hours - elapsed_hours, 0].max
  end

  def stability_percentage_remaining
    return 0.0 if stability_window_hours.zero?

    (stability_remaining_hours.to_f / stability_window_hours.to_f * 100).round(1)
  end

  def update_assessment(system_assessments)
    update!(
      event_status: :assessing,
      system_assessments: system_assessments,
      assessed_at: Time.current
    )
  end

  def update_decisions(strategic_decisions)
    update!(
      event_status: :deciding,
      strategic_decisions: strategic_decisions,
      decided_at: Time.current
    )
  end

  def update_execution(stabilization_results)
    update!(
      event_status: :executing,
      stabilization_results: stabilization_results,
      executed_at: Time.current
    )
  end

  def complete_event(learning_patterns)
    update!(
      event_status: :completed,
      learning_patterns: learning_patterns,
      completed_at: Time.current
    )
  end

  def fail_event(failure_reason)
    update!(
      event_status: :failed,
      failure_reason: failure_reason,
      failed_at: Time.current
    )
  end

  def completed?
    event_status == 'completed'
  end

  def failed?
    event_status == 'failed'
  end

  def active?
    ['triggered', 'assessing', 'deciding', 'executing'].include?(event_status)
  end

  def time_pressure_level
    remaining_pct = stability_percentage_remaining

    case remaining_pct
    when 75..100 then :low
    when 50..74 then :moderate
    when 25..49 then :high
    when 0..24 then :critical
    else :expired
    end
  end

  def em_harvested_total
    return 0 unless stabilization_results.present?

    stabilization_results.dig('em_harvested') || 0
  end

  def systems_stabilized_count
    return 0 unless stabilization_results.present?

    stabilization_results.dig('systems_stabilized') || 0
  end

  def aws_repurposed_count
    return 0 unless stabilization_results.present?

    stabilization_results.dig('aws_repurposed') || 0
  end

  def learning_patterns_count
    return 0 unless learning_patterns.present?

    learning_patterns.length
  end

  def duration_hours
    return nil unless completed_at && triggered_at

    ((completed_at - triggered_at) / 1.hour).round(1)
  end

  def success_metrics
    return {} unless completed?

    {
      em_harvested: em_harvested_total,
      systems_stabilized: systems_stabilized_count,
      aws_repurposed: aws_repurposed_count,
      learning_patterns_captured: learning_patterns_count,
      duration_hours: duration_hours,
      stability_window_utilized: (duration_hours.to_f / stability_window_hours.to_f * 100).round(1)
    }
  end
end