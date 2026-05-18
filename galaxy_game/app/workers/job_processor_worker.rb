class JobProcessorWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  def perform
    Rails.logger.info("JobProcessorWorker: processing all in-progress jobs")
    process_jobs(Job)
    promote_pending_jobs
  end
  # Promote pending jobs to in_progress if capacity is available
  def promote_pending_jobs
    # Find all settlements with pending jobs
    settlement_ids = Job.where(status: :pending).distinct.pluck(:settlement_id)
    Settlement::BaseSettlement.where(id: settlement_ids).find_each do |settlement|
      promote_jobs_for_settlement(settlement)
    end
  end

  def promote_jobs_for_settlement(settlement)
    # Group pending jobs by job_type
    pending_by_type = Job.where(settlement: settlement, status: :pending).group(:job_type).count
    pending_by_type.each do |job_type, count|
      next if count == 0
      # Find all units that support this job_type
      capable_units = settlement.base_units.select { |unit| unit.supports_job_type?(job_type) }
      total_capacity = capable_units.sum(&:max_concurrent_jobs)
      # Count in_progress jobs of this type at this settlement
      in_use = Job.where(settlement: settlement, job_type: job_type, status: :in_progress).count
      available_slots = total_capacity - in_use
      next if available_slots <= 0
      # Promote oldest pending jobs up to available_slots
      jobs_to_promote = Job.where(settlement: settlement, job_type: job_type, status: :pending).order(:created_at).limit(available_slots)
      jobs_to_promote.each do |job|
        production_time = begin
          job.operational_data&.dig('production_time_hours').to_f
        rescue
          nil
        end
        production_time = 1.0 if production_time.nil? || production_time <= 0
        job.update!(
          status: :in_progress,
          start_date: Time.current,
          completes_at: Time.current + production_time.hours
        )
        Rails.logger.info("JobProcessorWorker: promoted Job##{job.id} to in_progress for #{settlement.id} (#{job_type})")
      end
    end
  end

  private

  def process_jobs(job_class)
    jobs = job_class.where(status: :in_progress)
    Rails.logger.info("JobProcessorWorker: #{job_class.name} — #{jobs.count} in progress")

    jobs.each do |job|
      if job.respond_to?(:completes_at) && job.completes_at <= Time.current
        job.update!(status: :ready_to_claim)
      end
    rescue => e
      Rails.logger.error("JobProcessorWorker: failed to process #{job_class.name}##{job.id} — #{e.message}")
    end
  end
end
