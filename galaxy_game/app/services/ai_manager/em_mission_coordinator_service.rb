module AIManager
  class EmMissionCoordinatorService
    def self.assign_missions(settlement)
      # Deploy: satellites → NWA/AWS → mid skimmers
      available_skimmer = settlement.find_available("orbital_em_skimmer_mid")
      # ... mission logic
    end
  end
end
