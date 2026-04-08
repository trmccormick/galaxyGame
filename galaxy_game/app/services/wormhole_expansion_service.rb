# app/services/wormhole_expansion_service.rb
class WormholeExpansionService
  # Anchor quality mapping for stability duration (in years)
  ANCHOR_QUALITY_STABILITY = {
    high: 50,
    medium: 20,
    low: 5
  }.freeze

  def initialize
    # Initialize with default values
  end

  def find_expansion_opportunities
    # Only consider systems with available capacity and infrastructure-free deployment
    SolarSystem.where('wormhole_capacity > (SELECT COUNT(*) FROM wormholes WHERE solar_system_a_id = solar_systems.id OR solar_system_b_id = solar_systems.id)')
                .select { |sys| infrastructure_free_deployment_possible?(sys) }
  end

  # Check if a system can support infrastructure-free deployment (e.g., no major settlements required)
  def infrastructure_free_deployment_possible?(solar_system)
    # Correct delegation: settlements whose location.celestial_body.solar_system == solar_system
    settlements = Settlement::BaseSettlement.all.select do |s|
      s.location&.celestial_body&.solar_system == solar_system
    end
    settlements.all? { |s| s.type == :outpost || s.type == :none }
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
        wh.solar_system_b.remaining_wormhole_capacity >= wh.mass_limit &&
        wh.anchor_quality && ANCHOR_QUALITY_STABILITY.key?(wh.anchor_quality.to_sym)
      end
      
      # Prioritize Sol-to-Belt expansion
      prioritized = natural_wormholes.sort_by do |wh|
        [sol_to_belt_priority(wh), -ANCHOR_QUALITY_STABILITY[wh.anchor_quality.to_sym]]
      end
      prioritized.each do |wormhole|
        attempt_gate_construction(wormhole, organization)
      end
        # Returns 0 for Sol-to-Belt, 1 for others (Sol-to-Belt prioritized)
        def self.sol_to_belt_priority(wormhole)
          sol_ids = ["SOL", "Sol", "001"]
          belt_ids = ["BELT", "Belt", "ASTEROID_BELT"]
          ids = [wormhole.solar_system_a.identifier, wormhole.solar_system_b.identifier]
          if (ids & sol_ids).any? && (ids & belt_ids).any?
            0
          else
            1
          end
        end
    end
    
    def self.attempt_gate_construction(wormhole, organization)
      # Check if organization has required resources
      has_exotic_matter = check_organization_resources(organization, wormhole.required_exotic_matter)
      has_construction_materials = check_construction_materials(organization, wormhole.required_construction_materials)
      # New: Check AI resource policy (simulate AI expansion logic)
      return unless ai_resource_policy_allows_expansion?(organization, wormhole)
      if has_exotic_matter && has_construction_materials
        # Build the artificial gate with stability duration
        stability_years = ANCHOR_QUALITY_STABILITY[wormhole.anchor_quality.to_sym] || 5
        if wormhole.build_artificial_station!(stability_duration: stability_years)
          Rails.logger.info "#{organization.name} built artificial wormhole gate for wormhole #{wormhole.id} (#{stability_years} years stability)"
          consume_resources(organization, wormhole.required_exotic_matter, wormhole.required_construction_materials)
        end
      end
        # Simulate AI resource check for expansion
        def self.ai_resource_policy_allows_expansion?(organization, wormhole)
          # Example: Only allow if org has > 2x required exotic matter and construction materials
          # (Replace with real logic as needed)
          org_exotic = organization.account&.exotic_matter || 0
          org_materials = organization.account&.construction_materials || 0
          org_exotic >= 2 * (wormhole.required_exotic_matter || 0) && org_materials >= 2 * (wormhole.required_construction_materials || 0)
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