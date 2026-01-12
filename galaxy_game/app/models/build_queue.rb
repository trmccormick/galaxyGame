class BuildQueue
    def self.add_job(player_id, blueprint_id, settlement_id = nil)
      BuildJob.perform_async(player_id, blueprint_id, settlement_id)
    end
end
