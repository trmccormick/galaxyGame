# app/services/star_sim/wormholes/wormhole_discovery_service.rb
module StarSim::Wormholes
  # This service is responsible for detecting wormholes in a solar system.
  # It checks if a probe can discover a wormhole and creates a connection if successful.
  #
  # Example usage:
  #   DiscoveryService.detect_wormholes(probe)
  #
  # This will check if the probe can discover a wormhole and create it if possible.
  class DiscoveryService
    def self.detect_wormholes(probe)
      return unless probe.operational?
      
      system = probe.current_solar_system
      return if system.wormholes_detected?

      # Chance to discover based on probe capabilities
      if probe.detection_successful?
        Service.generate_connection(source_system: system)
        system.update!(wormholes_detected: true)
        
        # Create mission/notification for player
        # MissionService.create_wormhole_discovery_mission(
        #   system: system, 
        #   player: probe.owner
        # )

        # Trigger consortium formation after first wormhole discovery
        trigger_consortium_formation_if_needed
      end
    end

    private

    def self.trigger_consortium_formation_if_needed
      # Only form consortium once, after first wormhole discovery
      consortium = Organizations::BaseOrganization.find_by(identifier: 'WH-CONSORTIUM')
      return if consortium&.member_relationships&.any?

      # Check if core logistics corporations exist (minimum requirement)
      required_members = ['ASTROLIFT', 'ZENITH', 'VECTOR']
      existing_members = Organizations::BaseOrganization.where(identifier: required_members).pluck(:identifier)
      
      if existing_members.sort == required_members.sort
        puts "[DiscoveryService] Forming Wormhole Transit Consortium after first wormhole discovery" if defined?(Rails)
        Rails.logger.info "[DiscoveryService] Forming Wormhole Transit Consortium after first wormhole discovery" if defined?(Rails)
        WormholeConsortiumFormationService.form_consortium
      else
        missing = required_members - existing_members
        puts "[DiscoveryService] Cannot form consortium - missing core members: #{missing.join(', ')}" if defined?(Rails)
        Rails.logger.warn "[DiscoveryService] Cannot form consortium - missing core members: #{missing.join(', ')}" if defined?(Rails)
      end
    end
  end
end