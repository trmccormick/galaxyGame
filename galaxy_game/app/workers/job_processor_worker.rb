class JobProcessorWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  JOB_CLASSES = [
    MaterialProcessingJob,
    ComponentProductionJob,
    ShellPrintingJob,
    SealPrintingJob,
    ConstructionJob,
    SmeltingJob,
    UnitAssemblyJob,
    EnvironmentJob,
    ResourceJob
  ].freeze

  def perform(hours_elapsed = 1.0)
    Rails.logger.info("JobProcessorWorker: ticking all in-progress jobs for #{hours_elapsed}h")

    JOB_CLASSES.each do |job_class|
      tick_jobs(job_class, hours_elapsed)
    end
  end

  private

  def tick_jobs(job_class, hours_elapsed)
    jobs = job_class.where(status: 'in_progress')
    Rails.logger.info("JobProcessorWorker: #{job_class.name} — #{jobs.count} in progress")

    jobs.each do |job|
      job.process_tick(hours_elapsed)
    rescue => e
      Rails.logger.error("JobProcessorWorker: failed to tick #{job_class.name}##{job.id} — #{e.message}")
    end
  end
end
