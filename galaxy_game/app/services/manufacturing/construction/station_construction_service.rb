class Manufacturing::Construction::StationConstructionService
  def initialize(station)
    @station = station
  end

  # Orchestrates the construction of the station shell and core modules
  def build_station_shell
    install_airlock(
          position: 0,
          size: @station.main_airlock_size || "large",
          purpose: "crew_access"
        )
        install_docking_port(
          position: 1,
          purpose: "cargo_dock"
        )
        Array(@station.utility_trunks).each do |trunk|
          install_utility_connection(
            position: trunk.position,
            type: trunk.type,
            purpose: trunk.purpose || "power_life_support"
          )
        end
        install_airlock(
          position: @station.emergency_exit_position || 2,
          size: "small",
          purpose: "emergency_exit"
        )
      end

      private

      def install_airlock(position:, size:, purpose:)
        # 1. Get the specific Blueprint for the component (Airlock V2, for example)
        # 2. Get the Source Constraint tag from the main OrbitalDepot Blueprint
        
        # For illustration, let's assume the constraint is available:
        lunar_constraint = @station.blueprint.required_source_tag 
        
        # Calculate materials using StationCalculator
        # The calculator now outputs materials tagged with the constraint
        required_materials = StationCalculator.calculate_component_materials(
          'Airlock', 
          size: size, 
          source_tag: lunar_constraint # <--- KEY INTEGRATION POINT
        )

        # Create construction job, material/equipment requests, update status
        # This job will now ONLY consume materials with the 'LunarDerived' tag 
        # from the construction site's inventory.
        
        # Placeholder for integration
        puts "Scheduling airlock (#{purpose}) at position #{position}, size #{size} (Requires: #{lunar_constraint} resources)"
      end

      def install_docking_port(position:, purpose:)
        # Calculate materials using StationCalculator
        # Create construction job, material/equipment requests, update status
        puts "Scheduling docking port (#{purpose}) at position #{position}"
      end

      def install_utility_connection(position:, type:, purpose:)
        # Calculate materials using StationCalculator
        # Create construction job, material/equipment requests, update status
        puts "Scheduling utility connection (#{type}) at position #{position}, purpose #{purpose}"
      end
end
