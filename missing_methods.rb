    # Methods for operational mission planning tests
    def plan_mission(scenario)
      # Return a mission plan object
      MissionPlan.new(scenario, @settlement)
    end

    def allocate_resources(scenario)
      # Return a resource allocation result
      ResourceAllocationResult.new(scenario, @settlement)
    end

    def handle_emergency(conditions)
      # Return an emergency response
      EmergencyResponse.new(conditions, @settlement)
    end

    def upgrade_settlement(upgrades)
      # Return an upgrade result
      SettlementUpgrade.new(upgrades, @settlement)
    end

    def log_mission_outcome(outcome)
      # Log the mission outcome
      @log ||= []
      @log << outcome
    end

    def handle_no_resources
      # Handle the edge case of no available resources
      @status = 'idle'
    end

    def log
      # Return log object with entries
      LogWrapper.new(@log || [])
    end
  end

  # Helper classes for operational mission planning
  class MissionPl    # Methods for operational mise    def plan_mission(scenario)
      # Return a misen      # Return a mission planef      MissionPlan.new(scenario, @seas    end

    def allocate_resources(scenari


    ds R      # Return a resout
    def initi      ResourceAllocationResult.new(scenario     end

    def handle_emergency(conditions)
      # Reef
    dss?      # Return an emergency responsce      EmergencyResponse.new(conditicl    end

    def upgrade_settlement(upgrades)
     , 
    dmen      # Reconditions = conditions
         SettlementUpgrade.new(upg e    end

    def log_mission_outcome(outcome)
   
 
    d Se      # Log the mission outcome
   up      @log ||= []
      @log <ra      @log << ou     @settlement = settl
    d         # Handle the edge ca        @status = 'idle'
    end

    def log
      # Ral    end

    def log
nt
    d en      # Reen      LogWrapper.new(@log || [])
     e     end
end
