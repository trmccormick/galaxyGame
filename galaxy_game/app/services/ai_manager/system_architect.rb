module AIManager
  class SystemArchitect
        # Apply Sabatier refinements: maintenance tax discount if Sabatier Units are active
        def apply_sabatier_refinements(link_id)
          # Check if Sabatier units are active and apply discount
          if sabatier_units_active?(link_id)
            begin
              Rails.logger.info "[SystemArchitect] Applying Sabatier refinements for #{link_id} - discount already active via get_maintenance_tax_em"
            rescue
              puts "[SystemArchitect] Applying Sabatier refinements for #{link_id} - discount already active via get_maintenance_tax_em"
            end
          else
            begin
              Rails.logger.info "[SystemArchitect] Sabatier refinements not applied for #{link_id} - units inactive or insufficient H2"
            rescue
              puts "[SystemArchitect] Sabatier refinements not applied for #{link_id} - units inactive or insufficient H2"
            end
          end
        end
    # Calculate ROI for a wormhole link and trigger withdrawal if negative
    def calculate_link_roi(link_id)
      # Infrastructure Hook: Apply Sabatier refinements on every maintenance pulse
      apply_sabatier_refinements(link_id)

      # 1. Fetch tax from wormhole_contract.json
      base_tax = get_maintenance_tax_em(link_id)

      # 2. Apply 5x multiplier for Inter-Galactic/Cold Start links
      multiplier = get_inter_galactic_multiplier(link_id)
      total_em_cost = base_tax * multiplier

      # 3. Calculate Resource Value (from active drones/mining)
      current_yield_value = get_system_yield_value(link_id)

      # 4. Implement the 120% Threshold Rule
      if total_em_cost > (current_yield_value * 1.2)
        Rails.logger.warn "CRITICAL: Negative ROI detected for #{link_id}. Triggering Withdrawal Protocol."
        execute_unilateral_shift_sequence(link_id)
      end
    end

    # Forced Snap Sequence: Execute asset recall and mass dump for negative ROI links
    def execute_unilateral_shift_sequence(link_id)
      Rails.logger.info "[SystemArchitect] Initiating Unilateral Shift sequence for link #{link_id}"

      # Step 1: Recall all drones/satellites to Sol
      retrieve_assets_to_sol_anchor(link_id)

      # Step 2: Trigger Mass Dump to reset system coordinates
      trigger_mass_dump(link_id)

      Rails.logger.info "[SystemArchitect] Unilateral Shift sequence complete for link #{link_id}"
    end

        # Mass Dump logic: intentionally exceed mass limit to force Snap
        def trigger_mass_dump
          Rails.logger.info "[SystemArchitect] Triggering Mass Dump for #{celestial_body.name} to reset system coordinates"
          # Placeholder: Actual implementation should interact with Wormhole model to exceed mass limit
          # For now, just log the action
        end
    attr_reader :celestial_body, :system_config, :deployment_template, :logical_justifications

    def initialize(celestial_body)
      @celestial_body = celestial_body
      @system_config = analyze_system_configuration
      @logical_justifications = []
      @deployment_template = nil
      @stabilization_mode = nil
      @prioritize_sabatier = false
    end

    # Mandatory Withdrawal sequence for negative ROI links
    def execute_mandatory_withdrawal
      Rails.logger.info "[SystemArchitect] Executing Mandatory Withdrawal for #{celestial_body.name}"
      retrieve_assets_to_sol_anchor
      Rails.logger.info "[SystemArchitect] Mandatory Withdrawal complete"
    end

    # Main deployment method
    def deploy_autonomous_colonization
      Rails.logger.info "[SystemArchitect] Starting autonomous colonization for #{celestial_body.name}"

      # Check for Cold Start requirements
      if system_config[:cold_start]
        setup_cold_start_requirements
      end

      # Step 1: Deploy subsurface foothold (mandatory first step)
      deploy_subsurface_foothold

      # Step 2: Choose and execute strategic deployment template
      execute_deployment_template

      # Step 3: Transfer to system-specific corporation
      transfer_ownership_to_system_corp

      Rails.logger.info "[SystemArchitect] Colonization complete for #{celestial_body.name}"
    end

    private

    def analyze_system_configuration
      moons = CelestialBodies::CelestialBody.where(parent_celestial_body_id: celestial_body.id)
      large_moons = moons.select { |m| m.mass > 1e20 } # Rough threshold for large moons
      small_moons = moons.select { |m| m.mass.between?(1e18, 1e20) }

      cold_start = celestial_body.solar_system&.identifier == 'AC-01'

      {
        has_magnetosphere: celestial_body.has_magnetosphere,
        moon_count: moons.size,
        large_moons: large_moons,
        small_moons: small_moons,
        moonless: moons.empty?,
        preservation_mode: celestial_body.preservation_mode || false,
        cold_start: cold_start
      }
    end

    def setup_cold_start_requirements
      Rails.logger.info "[SystemArchitect] Setting up Cold Start requirements for #{celestial_body.name}"

      # Fuel Bridge: Set stabilization_mode to logistics_bridge
      # This would require active EM transport from Sol
      @stabilization_mode = 'logistics_bridge'
      Rails.logger.info "[SystemArchitect] Stabilization mode set to 'logistics_bridge' for Alpha Centauri link"

      # Sabatier Priority: If deploying to Proxima b, prioritize Sabatier Units
      if celestial_body.name == 'Proxima Centauri b'
        @prioritize_sabatier = true
        Rails.logger.info "[SystemArchitect] Prioritizing Sabatier Units for local CO2 fuel production"
      end
    end

    def retrieve_assets_to_sol_anchor
      # Logic to retrieve all mobile drones and stabilization satellites to Sol-side Anchor
      # This prevents them from becoming "Orphaned" during the Snap
      Rails.logger.info "[SystemArchitect] Retrieving all satellites and drones to Sol Anchor"

      # Placeholder: In a real implementation, this would query and command the assets
      # For now, just log the action
    end

    # SUBSURFACE PRIMITIVE: Mandatory first step for any solid body
    def deploy_subsurface_foothold
      Rails.logger.info "[SystemArchitect] Deploying subsurface foothold for #{celestial_body.name}"

      # Create settlement in subsurface location (lava tubes/caves)
      subsurface_location = create_subsurface_location

      # Deploy initial pressurized habitats
      settlement = deploy_initial_habitats(subsurface_location)

      # Establish basic infrastructure (power, comms, life support)
      establish_basic_infrastructure(settlement)

      # Load initial inventory from manifest
      load_initial_inventory(settlement)
    end

    def execute_deployment_template
      template = determine_deployment_template

      case template
      when :conversion
        execute_conversion_template
      when :lunar_standard
        execute_lunar_standard_template
      when :lunar_subsurface_settlement
        execute_lunar_subsurface_settlement_template
      when :asteroid_capture
        execute_asteroid_capture_template
      when :cycler_staging
        execute_cycler_staging_template
      end
    end

    def determine_deployment_template
      config = system_config

      # Special case for Moon: force lunar subsurface settlement
      if celestial_body.identifier == 'MOON'
        @deployment_template = :lunar_subsurface_settlement
        @logical_justifications << "Selected Lunar Subsurface Settlement template: Surface production prioritized to generate materials for future L1 Station construction"
        return @deployment_template
      end

      if config[:small_moons].size >= 2
        @deployment_template = :conversion # Mars Style
        @logical_justifications << "Selected Conversion template: #{config[:small_moons].size} small moons available for orbital reconfiguration and resource utilization"
      elsif config[:large_moons].any?
        @deployment_template = :lunar_standard # Earth Style
        @logical_justifications << "Selected Lunar Standard template: Large moon presence (#{config[:large_moons].size}) enables traditional surface base operations"
      elsif config[:moonless]
        # Check for nearby asteroids
        nearby_asteroid = find_nearby_asteroid
        if nearby_asteroid
          @deployment_template = :asteroid_capture
          @logical_justifications << "Selected Asteroid Capture template: Moonless body with nearby asteroid resources available for capture and utilization"
        else
          @deployment_template = :cycler_staging
          @logical_justifications << "Selected Cycler Staging template: Moonless body requiring orbital logistics infrastructure"
        end
      else
        @deployment_template = :cycler_staging # Venus Style
        @logical_justifications << "Selected Cycler Staging template: Orbital-only deployment suitable for atmospheric processing"
      end

      @deployment_template
    end

    # Template A: Conversion (Mars Style)
    def execute_conversion_template
      Rails.logger.info "[SystemArchitect] Executing Conversion template for #{celestial_body.name}"

      small_moons = @system_config[:small_moons]

      # Re-orbit and bore into small moons
      station_moon = small_moons.first
      depot_moon = small_moons.second

      # Deploy station on first moon
      deploy_orbital_station_on_moon(station_moon)

      # Deploy depot on second moon
      deploy_resource_depot_on_moon(depot_moon)
    end

    # Template B: Lunar-Standard (Earth Style)
    def execute_lunar_standard_template
      Rails.logger.info "[SystemArchitect] Executing Lunar-Standard template for #{celestial_body.name}"

      large_moon = @system_config[:large_moons].first

      # Build subsurface foothold on large moon (already done)
      # Deploy dedicated orbital station
      deploy_dedicated_orbital_station(large_moon)
    end

    # Template B.1: Lunar Subsurface Settlement (Moon Specific)
    def execute_lunar_subsurface_settlement_template
      Rails.logger.info "[SystemArchitect] Executing Lunar Subsurface Settlement template for #{celestial_body.name}"

      # Phase 1.1: Surface Extraction - Deploy Regolith Harvester, Electrolysis Unit (LOX), Smelter Unit
      deploy_surface_extraction_units

      # Phase 1.2: Domestic Storage - Luna Cryo Tank Farm (handled in subsurface foothold)
      # Phase 1.3: Orbital Construction - L1 Station (handled separately in pipeline)
    end

    # Template C: Asteroid Capture
    def execute_asteroid_capture_template
      Rails.logger.info "[SystemArchitect] Executing Asteroid Capture template for #{celestial_body.name}"

      asteroid = find_nearby_asteroid
      return unless asteroid

      # Deploy tug drones to relocate asteroid
      relocate_asteroid_to_orbit(asteroid)

      # Apply conversion template to captured asteroid
      execute_conversion_template_on_asteroid(asteroid)
    end

    # Template D: Cycler-Staging (Venus Style)
    def execute_cycler_staging_template
      Rails.logger.info "[SystemArchitect] Executing Cycler-Staging template for #{celestial_body.name}"

      # For stress test, just deploy basic systems
      settlement = Settlement::BaseSettlement.where("name LIKE ?", "%#{celestial_body.name}%").first
      if settlement
        deploy_power_system(settlement)
        deploy_comms_system(settlement)
        deploy_life_support(settlement)
      end
    end

    # Planetary Preservation enforcement
    def enforce_preservation_limits
      return unless @system_config[:preservation_mode]

      current_atmospheric_mass = celestial_body.atmosphere&.total_atmospheric_mass || 0
      original_mass = celestial_body.atmosphere&.original_atmospheric_mass || current_atmospheric_mass

      reduction_pct = ((original_mass - current_atmospheric_mass) / original_mass) * 100

      if reduction_pct >= 5.0
        disable_harvesting_firmware
        Rails.logger.warn "[SystemArchitect] #{celestial_body.name}: Atmospheric extraction disabled (5% cap reached)"
      end
    end

    def disable_harvesting_firmware
      # Disable all harvesting operations
      # Only restoration tasks can re-enable
    end

    # Economic integration
    def integrate_eap_ceiling_into_manifests
      # Integrate Earth Anchor Price ceiling from pricing JSONs
      # Use existing NpcPriceCalculator logic
    end

    def transfer_ownership_to_system_corp
      # Transfer from LDC/AstroLift to SystemSpecificCorp when operational
      system_corp = create_system_specific_corporation
      
      # Transfer settlements, structures, etc.
      transfer_settlements(system_corp)
      transfer_structures(system_corp)
      
      # Use LogisticsContract for any remaining NPC transfers
      establish_logistics_contracts(system_corp)
      
      Rails.logger.info "[SystemArchitect] Ownership transferred to #{system_corp.name}"
    end

    def create_system_specific_corporation
      corp_name = "#{celestial_body.name} Development Corporation"
      Organizations::BaseOrganization.find_or_create_by!(
        name: corp_name,
        identifier: celestial_body.name.parameterize.upcase
      ) do |org|
        org.organization_type = 'corporation'
      end
    end

    def transfer_settlements(system_corp)
      # Transfer settlements owned by bootstrap corp
      bootstrap_corp = find_bootstrap_corporation
      Settlement::BaseSettlement.where(owner: bootstrap_corp).update_all(owner_id: system_corp.id)
    end

    def transfer_structures(system_corp)
      # Transfer structures through settlements
      # Structures belong to settlements, so transferring settlements handles this
    end

    def establish_logistics_contracts(system_corp)
      # Create LogisticsContract for ongoing NPC-to-NPC transfers
      # Use existing InternalTransferService
    end

    # Helper methods
    def create_subsurface_location
      # Create location in natural geological voids (lava tubes/caves)
      location_name = "#{celestial_body.name} Subsurface Foothold"
      
      # Find existing or create new with unique coordinates
      existing_location = Location::CelestialLocation.find_by(
        name: location_name,
        celestial_body: celestial_body
      )
      
      return existing_location if existing_location
      
      # Generate unique coordinates
      latitude = rand(-90.0..90.0).round(3)
      longitude = rand(-180.0..180.0).round(3)
      lat_dir = latitude >= 0 ? 'N' : 'S'
      lon_dir = longitude >= 0 ? 'E' : 'W'
      
      Location::CelestialLocation.create!(
        name: location_name,
        celestial_body: celestial_body,
        coordinates: "#{latitude.abs}°#{lat_dir} #{longitude.abs}°#{lon_dir}",
        environmental_data: {
          radiation_shielding: true,
          thermal_stability: true,
          natural_caverns: true
        }
      )
    end

    def deploy_initial_habitats(location)
      # Deploy pressurized habitat modules
      habitat_settlement = Settlement::BaseSettlement.create!(
        name: "#{celestial_body.name} Subsurface Base",
        location: location,
        settlement_type: 'base',
        owner: find_bootstrap_corporation
      )

      # Create initial habitat structures
      create_habitat_structures(habitat_settlement)
      
      habitat_settlement
    end

    def establish_basic_infrastructure(settlement)
      # Deploy power, comms, life support systems
      deploy_power_system(settlement)
      deploy_comms_system(settlement)
      deploy_life_support(settlement)

      # Cold Start: Prioritize Sabatier Units for CO2 fuel production
      if @prioritize_sabatier
        deploy_sabatier_units(settlement)
      end

      # Infrastructure Hook: Apply Sabatier refinements after deployment
      apply_sabatier_refinements('SOL-AC-01') # Primary inter-galactic link
    end

    def deploy_sabatier_units(settlement)
      Rails.logger.info "[SystemArchitect] Deploying Sabatier Units for CO2 fuel production on #{celestial_body.name}"

      # Placeholder: Deploy Sabatier reactors to convert CO2 + H2 -> CH4 + H2O
      # This leverages the local CO2 atmosphere for fuel production
    end

    def load_initial_inventory(settlement)
      # Load initial supplies from bootstrap corporation
      bootstrap_corp = find_bootstrap_corporation
      initial_supplies = {
        'O2' => 1000,  # Oxygen
        'H2O' => 500,  # Water
        'food' => 200  # Food supplies
      }

      initial_supplies.each do |material, quantity|
        settlement.inventory.add_item(material, quantity)
      end
    end

    def find_nearby_asteroid
      # Find asteroid 10^15 to 10^17 kg in the same solar system
      min_mass = 1e15
      max_mass = 1e17
      
      CelestialBodies::CelestialBody.where(
        solar_system: celestial_body.solar_system,
        type: 'CelestialBodies::MinorBodies::Asteroid'
      ).where(
        'mass >= ? AND mass <= ?', min_mass, max_mass
      ).first
    end

    def deploy_orbital_station_on_moon(moon)
      # Deploy station
    end

    def deploy_resource_depot_on_moon(moon)
      # Deploy depot
    end

    def deploy_dedicated_orbital_station(moon)
      # Deploy station
    end

    def relocate_asteroid_to_orbit(asteroid)
      # Tug drones
    end

    def execute_conversion_template_on_asteroid(asteroid)
      # Apply conversion
    end

    def find_bootstrap_corporation
      # Use LDC or AstroLift as bootstrap
      Organizations::BaseOrganization.find_or_create_by!(
        name: 'Lunar Development Corporation',
        identifier: 'LDC'
      ) do |org|
        org.organization_type = 'corporation'
      end
    end

    def create_habitat_structures(settlement)
      # Create initial habitat domes/modules
      Structures::BaseStructure.create!(
        name: "Primary Habitat Module - #{settlement.name} - #{Time.now.to_i}-#{rand(1000)}",
        structure_name: 'habitat',
        settlement: settlement,
        owner: settlement.owner,
        operational_data: { 
          pressurized: true, 
          radiation_shielded: true, 
          structure_type: 'habitat',
          status: 'operational'
        }
      )
    end

    def deploy_power_system(settlement)
      # Deploy nuclear/solar power systems
      Structures::BaseStructure.create!(
        name: "Primary Power System - #{settlement.name} - #{Time.now.to_i}-#{rand(1000)}",
        structure_name: 'power_plant',
        settlement: settlement,
        owner: settlement.owner,
        operational_data: { 
          structure_type: 'power_plant',
          power_output: 1000 
        } # kW
      )
    end

    def deploy_comms_system(settlement)
      # Deploy communication systems
      Structures::BaseStructure.create!(
        name: "Communication Array - #{settlement.name} - #{Time.now.to_i}-#{rand(1000)}",
        structure_name: 'comms',
        settlement: settlement,
        owner: settlement.owner,
        operational_data: { structure_type: 'comms' }
      )
    end

    def deploy_life_support(settlement)
      # Deploy life support systems
      Structures::BaseStructure.create!(
        name: "Life Support System - #{settlement.name} - #{Time.now.to_i}-#{rand(1000)}",
        structure_name: 'life_support',
        settlement: settlement,
        owner: settlement.owner,
        operational_data: { 
          structure_type: 'life_support',
          o2_generation: 100, 
          co2_scrubbing: 80 
        } # kg/day
      )
    end

    def deploy_surface_extraction_units
      # Get the settlement from the last deployed
      settlement = Settlement::BaseSettlement.where(owner: find_bootstrap_corporation).last
      return unless settlement

      Rails.logger.info "[SystemArchitect] Deploying surface extraction units for #{celestial_body.name}"

      # Deploy Regolith Harvester
      deploy_unit_by_trait(settlement, 'Harvesting')

      # Deploy Electrolysis Unit for LOX
      deploy_unit_by_trait(settlement, 'Electrolysis')

      # Deploy Smelter Unit
      deploy_unit_by_trait(settlement, 'Smelting')
    end

    def deploy_unit_by_trait(settlement, trait)
      unit_lookup = Lookup::UnitLookupService.new
      units = unit_lookup.find_units_by_trait('traits', trait)
      return if units.empty?

      unit = units.first # Take the first matching unit
      Rails.logger.info "[SystemArchitect] Deploying #{unit['name']} for trait #{trait}"

      # Create a structure to hold the unit
      structure = Structures::BaseStructure.create!(
        name: "#{unit['name']} Structure - #{settlement.name} - #{Time.now.to_i}",
        structure_name: unit['name'].downcase.gsub(' ', '_'),
        settlement: settlement,
        location: settlement.location,
        owner: settlement.owner,
        operational_data: { structure_type: 'production' }
      )

      # Add the unit to the structure
      Units::BaseUnit.create!(
        name: unit['name'],
        unit_type: unit['type'] || 'production',
        attachable: structure,
        operational: true
      )
    end

    # Data-driven methods for wormhole contract compliance

    def get_maintenance_tax_em(link_id)
      contract_data = load_wormhole_contract

      # Try new structure first (link_registry)
      link_registry = contract_data['link_registry'] || []
      link_entry = link_registry.find { |link| link['link_id'] == link_id }

      if link_entry && link_entry.dig('stability_metrics', 'maintenance_tax_em')
        base_tax = link_entry.dig('stability_metrics', 'maintenance_tax_em')
      else
        # Fallback to old structure
        link_data = contract_data.dig('maintenance_taxes', 'links', link_id)
        base_tax = link_data['maintenance_tax_em'] if link_data

        # Default tax if link not found
        base_tax ||= contract_data.dig('maintenance_taxes', 'default') || 1000
      end

      # Apply Sabatier discount if active (25% reduction)
      if sabatier_units_active?(link_id)
        base_tax = (base_tax * 0.75).round(2)
        begin
          Rails.logger.info "[SystemArchitect] Sabatier Units Active: Maintenance Tax for #{link_id} reduced by 25% to #{base_tax} EM"
        rescue
          puts "[SystemArchitect] Sabatier Units Active: Maintenance Tax for #{link_id} reduced by 25% to #{base_tax} EM"
        end
      end

      base_tax
    end

    def sabatier_units_active?(link_id)
      # Check if Sabatier offset is active in contract logistics
      contract_data = load_wormhole_contract

      # Check link_registry for sabatier_offset_active flag
      link_registry = contract_data['link_registry'] || []
      link_entry = link_registry.find { |link| link['link_id'] == link_id }

      return false unless link_entry

      # Check if sabatier_offset_active is true in logistics
      logistics = link_entry['logistics'] || {}
      sabatier_active = logistics['sabatier_offset_active']

      # Additional check: ensure Sabatier units actually exist and have H2 feedstock
      if sabatier_active
        # Extract system identifier from link_id (e.g., "SOL-AC-01" -> "AC-01")
        system_id = link_id.split('-').last

        # Find the solar system and check for active Sabatier units with H2
        begin
          solar_system = SolarSystem.find_by(identifier: system_id)
          return false unless solar_system

          # Check if any settlement has Sabatier units with sufficient H2
          solar_system.celestial_bodies.each do |body|
            body.settlements.each do |settlement|
              # Check for Sabatier-related units
              sabatier_units = settlement.units.where("name LIKE ?", "%sabatier%")
              next if sabatier_units.empty?

              # Check if settlement has H2 feedstock
              h2_inventory = settlement.inventory_items.find_by(material_name: 'H2')
              if h2_inventory && h2_inventory.quantity > 100 # Minimum threshold
                begin
                  Rails.logger.info "[SystemArchitect] Sabatier Units confirmed active on #{body.name} with #{h2_inventory.quantity}kg H2"
                rescue
                  puts "[SystemArchitect] Sabatier Units confirmed active on #{body.name} with #{h2_inventory.quantity}kg H2"
                end
                return true
              end
            end
          end

          # If we get here, Sabatier units exist but no H2 - deactivate offset
          begin
            Rails.logger.warn "[SystemArchitect] Sabatier Units found but insufficient H2 feedstock - deactivating offset for #{link_id}"
          rescue
            puts "[SystemArchitect] Sabatier Units found but insufficient H2 feedstock - deactivating offset for #{link_id}"
          end
          return false
        rescue NameError
          # Models not loaded (test environment) - just check contract flag
          begin
            Rails.logger.info "[SystemArchitect] Models not available, using contract flag only for #{link_id}"
          rescue
            puts "[SystemArchitect] Models not available, using contract flag only for #{link_id}"
          end
          return sabatier_active
        end
      end

      false
    end

    def get_inter_galactic_multiplier(link_id)
      contract_data = load_wormhole_contract

      # Try new structure first (link_registry)
      link_registry = contract_data['link_registry'] || []
      link_entry = link_registry.find { |link| link['link_id'] == link_id }

      if link_entry
        # Add backward compatibility defaults for Wormhole Contract v1.2
        link_entry['type'] ||= 'Intra-Galactic'
        link_entry['em_environment'] ||= 'Hot_Start'
        link_entry['maintenance_multiplier'] ||= 1.0

        environment = link_entry['environment'] || link_entry['em_environment']
        return 5 if environment == 'Cold_Start'
        return 5 if link_entry['type'] == 'Targeted_Artificial' # Inter-galactic
      end

      # Fallback to old structure
      link_data = contract_data.dig('maintenance_taxes', 'links', link_id)

      if link_data
        return contract_data.dig('rules', 'inter_galactic_multiplier') || 5 if link_data['type'] == 'inter_galactic'
        return contract_data.dig('rules', 'cold_start_multiplier') || 5 if link_data['cold_start']
      end

      # Check if this is a cold start system (AC-01)
      return 5 if link_id.include?('AC-01') || link_id.include?('ALPHA-CENT')

      1 # Default multiplier
    end

    def get_system_yield_value(link_id)
      # Extract system identifier from link_id (e.g., "SOL-AC-01" -> "AC-01")
      system_id = link_id.split('-').last

      # Find the solar system and calculate total resource yield value
      solar_system = SolarSystem.find_by(identifier: system_id)
      return 0 unless solar_system

      # Sum up all mining operations in the system
      total_value = 0
      solar_system.celestial_bodies.each do |body|
        body.settlements.each do |settlement|
          # Calculate value of extracted resources
          settlement.inventory_items.each do |item|
            # Assume GCC market price for simplicity
            market_price = 100 # Placeholder - should fetch from market data
            total_value += item.quantity * market_price
          end
        end
      end

      total_value
    end

    def load_wormhole_contract
      @wormhole_contract ||= begin
        path = GalaxyGame::Paths::JSON_DATA.join('contract', 'wormhole_contract.json')
        JSON.parse(File.read(path))
      rescue
        # Fallback contract data
        {
          'maintenance_taxes' => {
            'default' => 1000,
            'links' => {}
          },
          'rules' => {
            'inter_galactic_multiplier' => 5,
            'cold_start_multiplier' => 5,
            'roi_threshold' => 1.2
          }
        }
      end
    end

    public

    def authorize_water_electrolysis_plant(water_source)
      Rails.logger.info "[SystemArchitect] Authorizing Water Electrolysis Plant construction for H2 supply to Proxima b Sabatier units"
      Rails.logger.info "[SystemArchitect] Water source discovered: #{water_source.class.name} - #{water_source.respond_to?(:name) ? water_source.name : 'Unknown'}"

      # Set authorization flag for water electrolysis plant
      @water_electrolysis_authorized = true
      @water_source = water_source

      # Queue construction of water electrolysis plant for Proxima b
      # This would integrate with the construction service
      queue_water_electrolysis_construction

      Rails.logger.info "[SystemArchitect] Water Electrolysis Plant authorization complete - H2 supply chain for Sabatier units enabled"
    end

    def queue_water_electrolysis_construction
      Rails.logger.info "[SystemArchitect] Queueing Water Electrolysis Plant construction"

      # Find Proxima b settlement
      proxima_b = find_proxima_b
      return unless proxima_b

      # Queue construction through construction service
      # This would integrate with Construction::LogisticsService
      # For now, log the intent
      Rails.logger.info "[SystemArchitect] Water Electrolysis Plant queued for Proxima b - will provide H2 feedstock for Sabatier units"
    end

    def find_proxima_b
      # Find the Proxima Centauri b celestial body
      # This would query the database
      # For now, return nil as placeholder
      nil
    end

    def initiate_alpha_centauri_scouting
      Rails.logger.info "[SystemArchitect] Initiating Alpha Centauri scouting mission"

      # Create ScoutLogic instance for Alpha Centauri system
      scout = AIManager::ScoutLogic.new(
        target_system: find_alpha_centauri_system,
        system_architect: self
      )

      # Execute scouting mission
      scout.execute_alpha_centauri_scouting
    end

    def find_alpha_centauri_system
      # Find or create the Alpha Centauri system
      # This would query SolarSystem model
      # For now, return a mock system
      MockSystem.new('Alpha Centauri')
    end

    def retrieve_assets_to_sol_anchor(link_id)
      Rails.logger.info "[SystemArchitect] Retrieving all satellites and drones to Sol Anchor for link #{link_id}"

      # Find all assets associated with this link
      # This would query Wormhole model and associated assets
      # For now, just log the action
    end

    def trigger_mass_dump(link_id)
      Rails.logger.info "[SystemArchitect] Triggering Mass Dump for link #{link_id} to reset system coordinates"

      # Find the wormhole and intentionally exceed mass limit
      # This would interact with Wormhole model to force a snap
      # For now, just log the action
    end
  end

  # Mock classes for simulation - would be replaced with actual model queries
  class MockSystem
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end
end
