module Structures
  class AccessPoint < ApplicationRecord
    self.table_name = 'access_points'
    belongs_to :lava_tube, class_name: 'CelestialBodies::Features::LavaTube', foreign_key: :lavatube_id
    
    # Maintain the enum from original model
    enum access_type: { large: 0, medium: 1, small: 2 }
    enum conversion_status: { 
      uncovered: 0, 
      sealed: 1, 
      airlock_installed: 2, 
      hangar_planned: 3,
      hangar_under_construction: 4,
      hangar_operational: 5,
      hangar_built: 6,
      connector_tunnel: 7 
    }
    
    # Connection to other structures (for tunnels, hangars, etc.)
    belongs_to :connected_structure, polymorphic: true, optional: true
    
    # For airlock installations
    has_one :installed_unit, class_name: 'Units::BaseUnit', as: :installation_location
    
    # Construction job tracking
    has_one :construction_job, as: :jobable, dependent: :destroy
    
    # Methods for different conversions
    def install_airlock(airlock_type = "standard_personnel_airlock")
      return false unless can_install_type?(airlock_type)
      
    service = Construction::AccessPointInstallationService.new(self, airlock_type)
      false
    end
    
    def build_hangar(hangar_type = "standard_rover_hangar")
      return false unless access_type == 'large'
      
      service = HangarConstructionService.new(self, hangar_type)
      if service.schedule_construction
        # Service handles status updates
        return true
      end
      false
    end
    
    def build_connector_tunnel(target_structure)
      return false unless can_connect_to?(target_structure)
      
      service = ConnectorTunnelService.new(self, target_structure)
      if service.schedule_construction
        # Service handles status updates
        return true
      end
      false
    end
    
    def seal_permanently
      service = AccessPointSealingService.new(self)
      if service.schedule_sealing
        # Service handles status updates
        return true
      end
      false
    end
    
    # Helper methods
    def can_install_type?(unit_type)
      # Check size compatibility
      case access_type
      when 'small'
        ['personnel_airlock_small', 'emergency_exit_hatch'].include?(unit_type)
      when 'medium'
        ['standard_personnel_airlock', 'cargo_airlock_medium'].include?(unit_type)
      when 'large'
        ['cargo_airlock_large', 'vehicle_airlock'].include?(unit_type)
      end
    end
    
    def can_connect_to?(structure)
      # Calculate if the structure is within connection range
      # This is a simplified example - would need proper distance calculation
      max_distance = 500 # meters
      
      # Get the positions
      structure_location = structure.location
      
      # This would need a proper calculation using coordinates
      true # Placeholder
    end
  end
end