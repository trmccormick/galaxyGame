# app/services/wormhole_expansion_service.rb
class WormholeExpansionService
  def initialize
    # Initialize with default values
  end

  def find_expansion_opportunities
    SolarSystem.where('wormhole_capacity > (SELECT COUNT(*) FROM wormholes WHERE solar_system_a_id = solar_systems.id OR solar_system_b_id = solar_systems.id)')
  end

  def create_gate_construction_contract(solar_system, player)
    provider = Logistics::Provider.first || begin
      org = Organizations::BaseOrganization.first || Organizations::BaseOrganization.create!(name: 'Test Org', identifier: 'TESTORG')
      Logistics::Provider.create!(name: 'Test Provider', identifier: 'TEST', reliability_rating: 3.0, base_fee_per_kg: 1.0, speed_multiplier: 1.0, organization: org)
    end
    Logistics::Contract.create!(
      material: 'wormhole_gate',
      quantity: 1,
      provider: provider,
      from_settlement: Settlement::BaseSettlement.first,
      to_settlement: Settlement::BaseSettlement.last,
      status: :pending,
      transport_method: :orbital_transfer
    )
  end

  def create_rescue_contract(player)
    provider = Logistics::Provider.first || begin
      org = Organizations::BaseOrganization.first || Organizations::BaseOrganization.create!(name: 'Test Org', identifier: 'TESTORG')
      Logistics::Provider.create!(name: 'Test Provider', identifier: 'TEST', reliability_rating: 3.0, base_fee_per_kg: 1.0, speed_multiplier: 1.0, organization: org)
    end
    Logistics::Contract.create!(
      material: 'player_rescue',
      quantity: 1,
      provider: provider,
      from_settlement: Settlement::BaseSettlement.first,
      to_settlement: Settlement::BaseSettlement.last,
      status: :pending,
      transport_method: :orbital_transfer
    )
  end
    
    def self.evaluate_artificial_gate_construction
      # LDC and AstroLift prioritize building Artificial Gates to Prize Targets
      eligible_organizations = Organization.where(name: ['Lunar Development Corporation', 'AstroLift Logistics'])
      
      eligible_organizations.each do |org|
        evaluate_organization_gate_construction(org)
      end
    end
    
    def self.evaluate_organization_gate_construction(organization)
      # Find natural wormholes connected to prize targets that can be converted
      natural_wormholes = Wormhole.natural.select do |wh|
        wh.can_build_artificial_station? && 
        wh.solar_system_a.remaining_wormhole_capacity >= wh.mass_limit &&
        wh.solar_system_b.remaining_wormhole_capacity >= wh.mass_limit
      end
      
      natural_wormholes.each do |wormhole|
        attempt_gate_construction(wormhole, organization)
      end
    end
    
    def self.attempt_gate_construction(wormhole, organization)
      # Check if organization has required resources
      has_exotic_matter = check_organization_resources(organization, wormhole.required_exotic_matter)
      has_construction_materials = check_construction_materials(organization, wormhole.required_construction_materials)
      
      if has_exotic_matter && has_construction_materials
        # Build the artificial gate
        if wormhole.build_artificial_station!
          Rails.logger.info "#{organization.name} successfully built artificial wormhole gate for wormhole #{wormhole.id}"
          
          # Consume resources
          consume_resources(organization, wormhole.required_exotic_matter, wormhole.required_construction_materials)
        end
      end
    end
    
    def self.handle_disconnected_players
      # Generate rescue contracts for disconnected players
      disconnected_players = Player.where(disconnected: true)
      
      disconnected_players.each do |player|
        create_rescue_contract(player)
      end
    end
    
    def self.create_rescue_contract(player)
      # Find the wormhole that stranded this player
      # This would need to be tracked when players get stranded
      # For now, create a generic rescue contract
      
      astro_lift = Organization.find_by(name: 'AstroLift Logistics')
      return unless astro_lift
      
      # Create high-reward rescue contract
      Logistics::Contract.create!(
        material: 'player_rescue',
        quantity: 1,
        provider: astro_lift,
        from_settlement: Settlement::BaseSettlement.first, # Origin settlement
        to_settlement: Settlement::BaseSettlement.last,    # Destination (would need to be tracked)
        status: :pending,
        transport_method: :emergency_rescue,
        special_instructions: "Emergency rescue for disconnected player #{player.name}",
        reward: 50000.0 # High reward for rescue missions
      )
    end
    
    private
    
    def self.check_organization_resources(organization, required_amount)
      # Check if organization has enough exotic matter
      account = organization.account
      return false unless account
      
      # Assume exotic matter is stored as an item in inventory
      # This would need to be implemented based on how resources are stored
      true # Placeholder
    end
    
    def self.check_construction_materials(organization, required_materials)
      # Check construction materials
      true # Placeholder
    end
    
    def self.consume_resources(organization, exotic_matter, materials)
      # Consume the required resources
      # Implementation depends on how resources are stored
    end
  end