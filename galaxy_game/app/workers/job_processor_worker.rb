class JobProcessorWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  def perform
    Rails.logger.info("JobProcessorWorker: processing all in-progress jobs (Job, ConstructionJob)")

    process_jobs(Job)
    process_jobs(ConstructionJob)
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
