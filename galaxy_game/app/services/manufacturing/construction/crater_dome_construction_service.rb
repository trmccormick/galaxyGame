module Manufacturing
  module Construction
    class CraterDomeConstructionService
      def initialize(owner, crater_dome)
        @owner = owner
        @crater_dome = crater_dome
      end

      def construct
        # Create a mock construction job
        job = ConstructionJob.create!(
          structure: @crater_dome,
          owner: @owner,
          status: 'pending'
        )

        { success: true, construction_job: job }
      end

      def start_construction(job)
        job.update(status: 'in_progress')
        true
      end
    end
  end
end