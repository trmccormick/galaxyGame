class BuildSkylightCoverJob
  include Sidekiq::Job
    queue_as :construction
  
    def perform(skylight)
      return unless skylight.pending_construction?
  
      materials_needed = SkylightConstructionService.calculate_materials(skylight)
      
      if Inventory.has_materials?(materials_needed)
        ConstructionManager.schedule_build(skylight, materials_needed)
        skylight.update(status: "under_construction")
      else
        ResourceManager.request_materials(materials_needed)
        skylight.update(status: "waiting_for_materials")
      end
    end
  end