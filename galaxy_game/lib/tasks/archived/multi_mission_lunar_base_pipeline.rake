# lib/tasks/multi_mission_lunar_base_pipeline.rake
require 'json'
require 'securerandom'

namespace :lunar_base do
  desc "Execute ISRU-Focused Multi-Mission Lunar Base Construction Pipeline (Realistic 6-12 Month Timeline)"
  task isru_focused: :environment do
    puts "\n🚀 === ISRU-FOCUSED LUNAR BASE CONSTRUCTION PIPELINE ==="
    puts "Building Lunar Base Alpha with maximum lunar resource utilization"
    puts "Prioritizing ISRU over Earth imports for sustainable settlement"

    # Initialize timeline tracking
    @mission_timeline = []
    @total_missions = 0
    @total_launches = 0
    @isru_metrics = { oxygen_produced: 0, water_produced: 0, fuel_produced: 0, earth_imports_reduced: 0 }

    # Execute Mission Series with ISRU focus
    execute_isru_mission_1_resource_extraction
    execute_isru_mission_2_power_habitat
    execute_isru_mission_3_life_support_manufacturing
    execute_isru_mission_4_expansion_self_sufficiency
    execute_isru_mission_5_research_export

    # Final Status Report
    display_isru_final_status
  end

  def execute_isru_mission_1_resource_extraction
    puts "\n⛏️ === MISSION 1: ISRU RESOURCE EXTRACTION FOUNDATION ==="
    puts "Launch Date: 2025-07-01 | Duration: 2 months | Focus: Lunar resource extraction over imports"
    puts "Goal: Establish ISRU as primary resource source from day one"

    @total_missions += 1
    @total_launches += 1

    # Setup Luna and landing site
    luna = setup_luna_environment
    landing_site = create_landing_site(luna, "Marius Hills ISRU Site")

    # Create Lunar Development Corporation
    ldc = create_lunar_development_corporation

    # Create initial settlement
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    settlement = create_initial_settlement(ldc, landing_site, "Lunar Base Alpha - ISRU Phase 1 - #{timestamp}")

    # Launch 1: ISRU-First Equipment
    puts "\n--- LAUNCH 1: ISRU Resource Extraction Systems ---"
    craft1 = launch_heavy_lift_transport("ISRU-Foundation-Haul-#{timestamp}", ldc)

    # Load ISRU-focused equipment
    load_isru_resource_equipment(craft1)

    # Land and deploy
    land_and_deploy_craft(craft1, settlement)

    # Execute ISRU construction phases
    puts "✓ SIMULATED: ISRU systems operational - producing oxygen and water from lunar resources"

    # Track ISRU production
    @isru_metrics[:oxygen_produced] += 500  # kg/month
    @isru_metrics[:water_produced] += 200   # kg/month

    # Track mission completion
    @mission_timeline << {
      mission: 1,
      name: "ISRU Resource Extraction Foundation",
      launch_date: "2025-07-01",
      completion_date: "2025-09-01",
      capabilities: ["Oxygen ISRU", "Water ISRU", "Regolith Processing", "Resource Independence"],
      settlement_population: 0,
      operational_status: "ISRU Operational",
      isru_priority: "MAXIMUM - All resources from lunar sources"
    }

    puts "✅ Mission 1 Complete: ISRU systems producing oxygen/water - no Earth imports for basic resources"
  end

  def execute_isru_mission_2_power_habitat
    puts "\n🏠 === MISSION 2: POWER & HABITAT WITH ISRU SUPPORT ==="
    puts "Launch Date: 2025-09-01 | Duration: 3 months | Focus: Power and habitat using ISRU materials"

    @total_missions += 1
    @total_launches += 1

    # Find existing settlement
    settlement = Settlement::BaseSettlement.where("name LIKE ?", "Lunar Base Alpha - ISRU Phase 1%").order(created_at: :desc).first
    settlement.update!(name: "Lunar Base Alpha - ISRU Phase 2 - #{Time.now.strftime("%Y%m%d_%H%M%S")}") if settlement

    # Launch 2: Power & Habitat (ISRU-assisted)
    puts "\n--- LAUNCH 2: Power & Habitat Systems ---"
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    craft2 = launch_heavy_lift_transport("Power-Habitat-ISRU-Haul-#{timestamp}", settlement.owner)

    # Load power and habitat equipment (minimized due to ISRU)
    load_isru_power_habitat_equipment(craft2)

    # Land and deploy
    land_and_deploy_craft(craft2, settlement)

    # Execute habitat construction using ISRU materials
    execute_isru_habitat_construction(settlement)

    # Track ISRU production increase
    @isru_metrics[:oxygen_produced] += 1000  # kg/month
    @isru_metrics[:water_produced] += 500    # kg/month
    @isru_metrics[:earth_imports_reduced] += 30  # % reduction

    # Track mission completion
    @mission_timeline << {
      mission: 2,
      name: "Power & Habitat with ISRU Support",
      launch_date: "2025-09-01",
      completion_date: "2025-12-01",
      capabilities: ["Solar Power", "ISRU Habitat Materials", "Pressurized Habitat", "Resource Recycling"],
      settlement_population: 2,
      operational_status: "Habitat Operational",
      isru_priority: "HIGH - Habitat materials from lunar resources where possible"
    }

    puts "✅ Mission 2 Complete: Habitat constructed using ISRU-produced materials and gases"
  end

  def execute_isru_mission_3_life_support_manufacturing
    puts "\n🌿 === MISSION 3: LIFE SUPPORT & ISRU MANUFACTURING ==="
    puts "Launch Date: 2025-12-01 | Duration: 2 months | Focus: Life support from ISRU, manufacturing from lunar materials"

    @total_missions += 1
    @total_launches += 1

    # Find existing settlement
    settlement = Settlement::BaseSettlement.where("name LIKE ?", "Lunar Base Alpha - ISRU Phase 2%").order(created_at: :desc).first
    settlement.update!(name: "Lunar Base Alpha - ISRU Phase 3 - #{Time.now.strftime("%Y%m%d_%H%M%S")}") if settlement

    # Launch 3: Life Support & Manufacturing
    puts "\n--- LAUNCH 3: Life Support & ISRU Manufacturing ---"
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    craft3 = launch_heavy_lift_transport("Life-Support-ISRU-Manufacturing-Haul-#{timestamp}", settlement.owner)

    # Load life support and manufacturing equipment
    load_isru_life_support_manufacturing_equipment(craft3)

    # Land and deploy
    land_and_deploy_craft(craft3, settlement)

    # Execute life support expansion using ISRU
    execute_isru_life_support_expansion(settlement)

    # Track ISRU production increase
    @isru_metrics[:oxygen_produced] += 2000  # kg/month
    @isru_metrics[:water_produced] += 1000   # kg/month
    @isru_metrics[:fuel_produced] += 100     # kg/month
    @isru_metrics[:earth_imports_reduced] += 50  # % reduction

    # Track mission completion
    @mission_timeline << {
      mission: 3,
      name: "Life Support & ISRU Manufacturing",
      launch_date: "2025-12-01",
      completion_date: "2026-02-01",
      capabilities: ["ISRU Life Support", "3D Printing from Lunar Materials", "Fuel Production", "Waste Recycling"],
      settlement_population: 4,
      operational_status: "Self-Sustaining Life Support",
      isru_priority: "CRITICAL - All life support gases from lunar resources"
    }

    puts "✅ Mission 3 Complete: Life support fully ISRU-based, manufacturing uses lunar materials"
  end

  def execute_isru_mission_4_expansion_self_sufficiency
    puts "\n🏭 === MISSION 4: EXPANSION & FULL SELF-SUFFICIENCY ==="
    puts "Launch Date: 2026-02-01 | Duration: 3 months | Focus: Base expansion using ISRU materials, full independence"

    @total_missions += 1
    @total_launches += 1

    # Find existing settlement
    settlement = Settlement::BaseSettlement.where("name LIKE ?", "Lunar Base Alpha - ISRU Phase 3%").order(created_at: :desc).first
    settlement.update!(name: "Lunar Base Alpha - ISRU Phase 4 - #{Time.now.strftime("%Y%m%d_%H%M%S")}") if settlement

    # Launch 4: Expansion & Self-Sufficiency
    puts "\n--- LAUNCH 4: Expansion & ISRU Self-Sufficiency ---"
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    craft4 = launch_heavy_lift_transport("Expansion-ISRU-Self-Sufficiency-Haul-#{timestamp}", settlement.owner)

    # Load expansion equipment (minimal due to ISRU manufacturing)
    load_isru_expansion_equipment(craft4)

    # Land and deploy
    land_and_deploy_craft(craft4, settlement)

    # Execute expansion using ISRU-manufactured components
    execute_isru_expansion(settlement)

    # Track ISRU production increase
    @isru_metrics[:oxygen_produced] += 5000  # kg/month
    @isru_metrics[:water_produced] += 2000   # kg/month
    @isru_metrics[:fuel_produced] += 500     # kg/month
    @isru_metrics[:earth_imports_reduced] += 80  # % reduction

    # Track mission completion
    @mission_timeline << {
      mission: 4,
      name: "Expansion & Full Self-Sufficiency",
      launch_date: "2026-02-01",
      completion_date: "2026-05-01",
      capabilities: ["ISRU Construction Materials", "Fuel Export", "Resource Surplus", "Minimal Earth Dependency"],
      settlement_population: 6,
      operational_status: "Fully Self-Sufficient",
      isru_priority: "COMPLETE - All construction and operations from lunar resources"
    }

    puts "✅ Mission 4 Complete: Base expansion using ISRU-manufactured materials, producing resource surplus"
  end

  def execute_isru_mission_5_research_export
    puts "\n🔬 === MISSION 5: RESEARCH & RESOURCE EXPORT ==="
    puts "Launch Date: 2026-05-01 | Duration: 2 months | Focus: Research facilities and lunar resource export"

    @total_missions += 1
    @total_launches += 1

    # Find existing settlement
    settlement = Settlement::BaseSettlement.where("name LIKE ?", "Lunar Base Alpha - ISRU Phase 4%").order(created_at: :desc).first
    settlement.update!(name: "Lunar Base Alpha - ISRU Operational - #{Time.now.strftime("%Y%m%d_%H%M%S")}") if settlement

    # Launch 5: Research & Export
    puts "\n--- LAUNCH 5: Research & ISRU Export ---"
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    craft5 = launch_heavy_lift_transport("Research-ISRU-Export-Haul-#{timestamp}", settlement.owner)

    # Load research equipment (manufactured on-site where possible)
    load_isru_research_equipment(craft5)

    # Land and deploy
    land_and_deploy_craft(craft5, settlement)

    # Execute research operations
    execute_isru_research_operations(settlement)

    # Track final ISRU production
    @isru_metrics[:oxygen_produced] += 10000 # kg/month
    @isru_metrics[:water_produced] += 5000   # kg/month
    @isru_metrics[:fuel_produced] += 2000    # kg/month
    @isru_metrics[:earth_imports_reduced] += 95  # % reduction

    # Track mission completion
    @mission_timeline << {
      mission: 5,
      name: "Research & Resource Export",
      launch_date: "2026-05-01",
      completion_date: "2026-07-01",
      capabilities: ["Advanced Research", "Resource Export", "ISRU Technology Development", "Economic Viability"],
      settlement_population: 8,
      operational_status: "Resource Export Hub",
      isru_priority: "ECONOMIC - Lunar resources as primary export product"
    }

    puts "✅ Mission 5 Complete: Research operational, base exporting lunar resources to Earth"
  end

  def execute_mission_1_power_infrastructure
    puts "\n📡 === MISSION 1: POWER & INFRASTRUCTURE FOUNDATION ==="
    puts "Launch Date: 2025-07-01 | Duration: 2 months | Focus: Power grid & basic infrastructure"

    @total_missions += 1
    @total_launches += 1

    # Setup Luna and landing site
    luna = setup_luna_environment
    landing_site = create_landing_site(luna, "Marius Hills Base Camp")

    # Create Lunar Development Corporation
    ldc = create_lunar_development_corporation

    # Create initial settlement
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    settlement = create_initial_settlement(ldc, landing_site, "Lunar Base Alpha - Phase 1 - #{timestamp}")

    # Launch 1: Power & Communications Infrastructure
    puts "\n--- LAUNCH 1: Power & Comms Infrastructure ---"
    craft1 = launch_heavy_lift_transport("Power-Infrastructure-Haul-#{timestamp}", ldc)

    # Load Mission 1 equipment (based on lunar-precursor-1)
    load_power_infrastructure_equipment(craft1)

    # Land and deploy
    land_and_deploy_craft(craft1, settlement)

    # Execute AI-managed construction phases (SIMULATED)
    puts "✓ SIMULATED: AI-managed construction phases completed - power grid operational"

    # Track mission completion
    @mission_timeline << {
      mission: 1,
      name: "Power & Infrastructure Foundation",
      launch_date: "2025-07-01",
      completion_date: "2025-09-01",
      capabilities: ["Power Grid", "Communications", "Basic ISRU", "Construction Equipment"],
      settlement_population: 0,
      operational_status: "Infrastructure Ready"
    }

    puts "✅ Mission 1 Complete: Power infrastructure operational, ISRU foundation established"
  end

  def execute_mission_2_habitat_foundation
    puts "\n🏠 === MISSION 2: HABITAT FOUNDATION ==="
    puts "Launch Date: 2025-09-01 | Duration: 3 months | Focus: Pre-constructed habitat components"

    @total_missions += 1
    @total_launches += 1

    # Find existing settlement
    settlement = Settlement::BaseSettlement.where("name LIKE ?", "Lunar Base Alpha - Phase 1%").order(created_at: :desc).first
    unless settlement
      puts "❌ Error: Mission 1 settlement not found!"
      return
    end

    # Update settlement name for Phase 2
    settlement.update!(name: "Lunar Base Alpha - Phase 2 - #{Time.now.strftime("%Y%m%d_%H%M%S")}")

    # Launch 2: Habitat Components
    puts "\n--- LAUNCH 2: Habitat Components ---"
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    craft2 = launch_heavy_lift_transport("Habitat-Foundation-Haul-#{timestamp}", settlement.owner)

    # Load Mission 2 equipment (based on lunar-precursor-2)
    load_habitat_foundation_equipment(craft2)

    # Land and deploy
    land_and_deploy_craft(craft2, settlement)

    # Execute habitat construction phases
    execute_habitat_construction_phases(settlement)

    # Track mission completion
    @mission_timeline << {
      mission: 2,
      name: "Habitat Foundation",
      launch_date: "2025-09-01",
      completion_date: "2025-12-01",
      capabilities: ["Airlocks", "Skylight Covers", "Pressurization Systems", "Dust Mitigation"],
      settlement_population: 2,
      operational_status: "Habitat Pressurized"
    }

    puts "✅ Mission 2 Complete: Lava tube habitat sealed and pressurized"
  end

  def execute_mission_3_life_support_expansion
    puts "\n🌿 === MISSION 3: LIFE SUPPORT EXPANSION ==="
    puts "Launch Date: 2025-12-01 | Duration: 2 months | Focus: Full life support & crew arrival"

    @total_missions += 1
    @total_launches += 1

    # Find existing settlement
    settlement = Settlement::BaseSettlement.where("name LIKE ?", "Lunar Base Alpha - Phase 2%").order(created_at: :desc).first
    settlement.update!(name: "Lunar Base Alpha - Phase 3 - #{Time.now.strftime("%Y%m%d_%H%M%S")}") if settlement

    # Launch 3: Life Support Systems
    puts "\n--- LAUNCH 3: Life Support Expansion ---"
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    craft3 = launch_heavy_lift_transport("Life-Support-Expansion-Haul-#{timestamp}", settlement.owner)

    # Load advanced life support equipment
    load_life_support_equipment(craft3)

    # Land and deploy
    land_and_deploy_craft(craft3, settlement)

    # Execute life support expansion
    execute_life_support_expansion(settlement)

    # Track mission completion
    @mission_timeline << {
      mission: 3,
      name: "Life Support Expansion",
      launch_date: "2025-12-01",
      completion_date: "2026-02-01",
      capabilities: ["Full Life Support", "Crew Quarters", "Greenhouse", "Waste Management"],
      settlement_population: 4,
      operational_status: "Crew Operational"
    }

    puts "✅ Mission 3 Complete: Full life support operational, crew arrival capability"
  end

  def execute_mission_4_industrial_capability
    puts "\n🏭 === MISSION 4: INDUSTRIAL CAPABILITY ==="
    puts "Launch Date: 2026-02-01 | Duration: 3 months | Focus: Manufacturing & resource processing"

    @total_missions += 1
    @total_launches += 1

    # Find existing settlement
    settlement = Settlement::BaseSettlement.where("name LIKE ?", "Lunar Base Alpha - Phase 3%").order(created_at: :desc).first
    settlement.update!(name: "Lunar Base Alpha - Phase 4 - #{Time.now.strftime("%Y%m%d_%H%M%S")}") if settlement

    # Launch 4: Industrial Equipment
    puts "\n--- LAUNCH 4: Industrial Capability ---"
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    craft4 = launch_heavy_lift_transport("Industrial-Capability-Haul-#{timestamp}", settlement.owner)

    # Load industrial manufacturing equipment
    load_industrial_equipment(craft4)

    # Land and deploy
    land_and_deploy_craft(craft4, settlement)

    # Execute industrial expansion
    execute_industrial_expansion(settlement)

    # Track mission completion
    @mission_timeline << {
      mission: 4,
      name: "Industrial Capability",
      launch_date: "2026-02-01",
      completion_date: "2026-05-01",
      capabilities: ["Manufacturing", "Material Refining", "Fuel Production", "Export Capability"],
      settlement_population: 6,
      operational_status: "Self-Sustaining"
    }

    puts "✅ Mission 4 Complete: Industrial manufacturing operational, resource export capability"
  end

  def execute_mission_5_research_operations
    puts "\n🔬 === MISSION 5: RESEARCH OPERATIONS ==="
    puts "Launch Date: 2026-05-01 | Duration: 2 months | Focus: Research facilities & long-term operations"

    @total_missions += 1
    @total_launches += 1

    # Find existing settlement
    settlement = Settlement::BaseSettlement.where("name LIKE ?", "Lunar Base Alpha - Phase 4%").order(created_at: :desc).first
    settlement.update!(name: "Lunar Base Alpha - Operational - #{Time.now.strftime("%Y%m%d_%H%M%S")}") if settlement

    # Launch 5: Research Equipment
    puts "\n--- LAUNCH 5: Research Operations ---"
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    craft5 = launch_heavy_lift_transport("Research-Operations-Haul-#{timestamp}", settlement.owner)

    # Load research and advanced equipment
    load_research_equipment(craft5)

    # Land and deploy
    land_and_deploy_craft(craft5, settlement)

    # Execute research facility setup
    execute_research_operations(settlement)

    # Track mission completion
    @mission_timeline << {
      mission: 5,
      name: "Research Operations",
      launch_date: "2026-05-01",
      completion_date: "2026-07-01",
      capabilities: ["Research Labs", "Advanced ISRU", "Crew Expansion", "Long-term Operations"],
      settlement_population: 8,
      operational_status: "Fully Operational"
    }

    puts "✅ Mission 5 Complete: Research operations established, base fully operational"
  end

  # Helper Methods

  def setup_luna_environment
    puts "Setting up Luna celestial body..."
    earth = CelestialBodies::Planets::Rocky::TerrestrialPlanet.find_or_create_by!(name: "Earth") do |e|
      e.identifier = 'EARTH-01'
      e.mass = 5.972e24
      e.size = 6371.0
      e.gravity = 9.807
    end

    luna = CelestialBodies::Satellites::Moon.find_or_create_by!(identifier: 'LUNA-01') do |body|
      body.name = "Luna"
      body.mass = 7.342e22
      body.radius = 1737400
      body.size = 0.2724
      body.gravity = 0.1654
      body.surface_temperature = 250.0
      body.parent_celestial_body = earth
    end
    puts "✓ Luna environment ready"
    luna
  end

  def create_landing_site(luna, site_name)
    landing_site = Location::CelestialLocation.find_or_create_by!(
      name: site_name,
      coordinates: "14.1°N 56.8°W",
      celestial_body: luna
    )
    puts "✓ Landing site established: #{site_name}"
    landing_site
  end

  def create_lunar_development_corporation
    ldc = Organizations::BaseOrganization.find_or_create_by!(identifier: 'LDC') do |org|
      org.name = 'Lunar Development Corporation'
      org.organization_type = :development_corporation
      org.operational_data = { 'is_npc' => true }
    end
    puts "✓ Lunar Development Corporation established"
    ldc
  end

  def create_initial_settlement(owner, location, name)
    settlement = Settlement::BaseSettlement.find_or_create_by!(name: name) do |s|
      s.owner = owner
      s.location = location
      s.current_population = 0
      s.settlement_type = :outpost
    end
    settlement.create_inventory! unless settlement.inventory
    puts "✓ Initial settlement created: #{name}"
    settlement
  end

  def launch_heavy_lift_transport(name, owner)
    craft = Craft::Transport::HeavyLander.create!(
      name: name,
      craft_name: "Heavy Lift Transport",
      craft_type: "transport",
      owner: owner,
      deployed: false
    )
    craft.create_inventory! unless craft.inventory
    puts "✓ Heavy Lift Transport launched: #{name}"
    craft
  end

  def load_power_infrastructure_equipment(craft)
    # Based on lunar-precursor-1 manifest - SIMULATED loading
    equipment = [
      { name: "CAR-300 Lunar Deployment Robot Mk1", count: 2 },
      { name: "Planetary Umbilical Hub", count: 1 },
      { name: "Planetary Power Management Unit", count: 1 },
      { name: "Radioisotope Thermoelectric Generator", count: 1 },
      { name: "Comms Equipment", count: 1 },
      { name: "SMR-500 Surveyor Mk1", count: 1 },
      { name: "HRV-400 Resource Harvester Mk1", count: 1 },
      { name: "Compact Solar Panel", count: 10 },
      { name: "Regolith Shell Printer Mk1", count: 1 },
      { name: "Planetary Volatiles Extractor Mk1", count: 1 },
      { name: "Planetary I-Beam Printing Unit", count: 1 },
      { name: "Thermal Extraction Unit", count: 1 },
      { name: "Surface Preparation Unit", count: 1 }
    ]

    # Simulate loading (don't create actual Item records to avoid validation issues)
    total_items = equipment.sum { |e| e[:count] }
    puts "✓ SIMULATED: Loaded #{total_items} power & infrastructure items onto #{craft.name}"
    total_items
  end

  def load_habitat_foundation_equipment(craft)
    # Based on lunar-precursor-2 manifest - SIMULATED loading
    equipment = [
      { name: "Pre-constructed Lava Tube Airlock", count: 1 },
      { name: "Pre-constructed Skylight Covers", count: 3 },
      { name: "CAR-300 Lunar Deployment Robot Mk1", count: 2 },
      { name: "Lava Tube Pressurization System", count: 1 },
      { name: "Atmospheric Processing Unit", count: 1 },
      { name: "Dust Mitigation System", count: 1 },
      { name: "Inflatable Habitat Unit", count: 2 }
    ]

    total_items = equipment.sum { |e| e[:count] }
    puts "✓ SIMULATED: Loaded #{total_items} habitat foundation items onto #{craft.name}"
    total_items
  end

  def load_life_support_equipment(craft)
    equipment = [
      { name: "Water Recycling Unit", count: 2 },
      { name: "CO2 Oxygen Production Unit", count: 2 },
      { name: "Waste Management Unit", count: 1 },
      { name: "Inflatable Greenhouse", count: 2 },
      { name: "Advanced Life Support Module", count: 1 },
      { name: "Crew Quarters Module", count: 4 }
    ]

    total_items = equipment.sum { |e| e[:count] }
    puts "✓ SIMULATED: Loaded #{total_items} life support items onto #{craft.name}"
    total_items
  end

  def load_industrial_equipment(craft)
    equipment = [
      { name: "Material Refining Plant", count: 1 },
      { name: "3D Printing Factory", count: 1 },
      { name: "Fuel Production Plant", count: 1 },
      { name: "Export Processing Facility", count: 1 },
      { name: "Heavy Manufacturing Unit", count: 2 },
      { name: "Resource Storage Depot", count: 1 }
    ]

    total_items = equipment.sum { |e| e[:count] }
    puts "✓ SIMULATED: Loaded #{total_items} industrial items onto #{craft.name}"
    total_items
  end

  def load_research_equipment(craft)
    equipment = [
      { name: "Research Laboratory", count: 2 },
      { name: "Advanced ISRU Plant", count: 1 },
      { name: "Crew Expansion Module", count: 2 },
      { name: "Long-term Operations Center", count: 1 },
      { name: "Scientific Instruments Suite", count: 1 },
      { name: "Data Processing Center", count: 1 }
    ]

    total_items = equipment.sum { |e| e[:count] }
    puts "✓ SIMULATED: Loaded #{total_items} research items onto #{craft.name}"
    total_items
  end

  def land_and_deploy_craft(craft, settlement)
    craft.update!(deployed: true, docked_at: settlement)

    # SIMULATED: Transfer all cargo to settlement (don't create actual Item records)
    simulated_item_count = 25 + rand(15) # Simulate 25-40 items transferred
    puts "✓ SIMULATED: Craft landed and #{simulated_item_count} items transferred to settlement"
    simulated_item_count
  end

  def execute_habitat_construction_phases(settlement)
    puts "Executing habitat construction phases..."

    # Create lava tube features
    lava_tube = CelestialBodies::Features::LavaTube.find_or_create_by!(
      celestial_body: settlement.location.celestial_body,
      feature_id: "alpha_lava_tube"
    ) do |feature|
      feature.feature_type = "lava_tube"
      feature.status = "surveyed"
      feature.static_data = {
        name: "Alpha Lava Tube",
        dimensions: { length_m: 600.0, width_m: 60.0, height_m: 35.0 }
      }
    end

    skylight = CelestialBodies::Features::Skylight.find_or_create_by!(
      celestial_body: settlement.location.celestial_body,
      feature_id: "alpha_skylight"
    ) do |feature|
      feature.parent_feature = lava_tube
      feature.feature_type = "skylight"
      feature.status = "natural"
      feature.static_data = { diameter_m: 30.0 }
    end

    # Schedule and complete habitat construction
    skylight_job = ConstructionJob.create!(
      job_type: 'skylight_cover',
      status: 'completed',
      settlement: settlement,
      jobable: skylight,
      priority: 'high'
    )

    puts "✓ SIMULATED: Habitat construction completed - lava tube sealed and pressurized"
  end

  def execute_life_support_expansion(settlement)
    puts "Expanding life support systems..."
    # Simulate life support expansion
    settlement.update!(current_population: 4)
    puts "✓ Life support expanded for crew operations"
  end

  def execute_industrial_expansion(settlement)
    puts "Establishing industrial capabilities..."
    settlement.update!(current_population: 6)
    puts "✓ Industrial manufacturing and resource processing operational"
  end

  def execute_research_operations(settlement)
    puts "Establishing research operations..."
    settlement.update!(current_population: 8)
    puts "✓ Research facilities and long-term operations established"
  end

  def display_final_status
    puts "\n🏛️ === FINAL LUNAR BASE STATUS ==="
    puts "Multi-Mission Construction Complete (6-12 Month Timeline)"
    puts "=" * 60

    settlement = Settlement::BaseSettlement.where("name LIKE ?", "Lunar Base Alpha - Operational%").order(created_at: :desc).first
    if settlement
      puts "\nBase Information:"
      puts "  Name: #{settlement.name}"
      puts "  Owner: #{settlement.owner.name}"
      puts "  Population: #{settlement.current_population} crew"
      puts "  Location: #{settlement.location.name}"

      puts "\nMission Timeline:"
      @mission_timeline.each do |mission|
        puts "  Mission #{mission[:mission]}: #{mission[:name]}"
        puts "    Launch: #{mission[:launch_date]} | Complete: #{mission[:completion_date]}"
        puts "    Population: #{mission[:settlement_population]} | Status: #{mission[:operational_status]}"
        puts "    Capabilities: #{mission[:capabilities].join(', ')}"
        puts ""
      end

      puts "Summary Statistics:"
      puts "  Total Missions: #{@total_missions}"
      puts "  Total Launches: #{@total_launches}"
      puts "  Construction Duration: 12 months"
      puts "  Final Population: #{settlement.current_population}"
      puts "  Operational Status: Fully Operational Lunar Base"

      puts "\nKey Achievements:"
      puts "  ✅ Power infrastructure with RTG + solar backup"
      puts "  ✅ ISRU systems producing oxygen, water, and fuel"
      puts "  ✅ Pressurized lava tube habitat (600m × 60m × 35m)"
      puts "  ✅ Industrial manufacturing and resource export"
      puts "  ✅ Research facilities and crew accommodations"
      puts "  ✅ Self-sustaining operations capability"
    else
      puts "❌ Final settlement not found!"
    end

    puts "\n🎯 Multi-Mission Lunar Base Construction Pipeline Complete!"
  end

  # ISRU-Focused Equipment Loading Methods
  def load_isru_resource_equipment(craft)
    puts "Loading ISRU-focused resource extraction equipment..."

    # ISRU systems prioritized over imported materials
    equipment = [
      { name: "Planetary Volatiles Extractor", quantity: 2, purpose: "Extract oxygen and water from lunar regolith" },
      { name: "Thermal Extraction Unit", quantity: 1, purpose: "Process lunar materials for construction" },
      { name: "Gas Conversion Unit", quantity: 1, purpose: "Convert extracted gases for life support" },
      { name: "Regolith Processing Plant", quantity: 1, purpose: "Process lunar soil for ISRU feedstock" },
      { name: "Resource Storage System", quantity: 1, purpose: "Store ISRU-produced resources" }
    ]

    equipment.each do |item|
      puts "  ✓ #{item[:quantity]}x #{item[:name]} - #{item[:purpose]}"
    end

    # Simulate loading
    puts "✓ ISRU equipment loaded - lunar resources will be primary source"
  end

  def load_isru_power_habitat_equipment(craft)
    puts "Loading power and habitat equipment (ISRU-assisted construction)..."

    # Minimal imported materials due to ISRU
    equipment = [
      { name: "Solar Power Array", quantity: 4, purpose: "Provide power using lunar sunlight" },
      { name: "Habitat Module Frame", quantity: 2, purpose: "Structural frame (some materials from ISRU)" },
      { name: "Pressurization System", quantity: 1, purpose: "Seal and pressurize habitat using ISRU gases" },
      { name: "ISRU Construction Support", quantity: 1, purpose: "Use lunar materials for habitat completion" }
    ]

    equipment.each do |item|
      puts "  ✓ #{item[:quantity]}x #{item[:name]} - #{item[:purpose]}"
    end

    puts "✓ Power/habitat equipment loaded - ISRU provides construction materials"
  end

  def load_isru_life_support_manufacturing_equipment(craft)
    puts "Loading life support and ISRU manufacturing equipment..."

    equipment = [
      { name: "ISRU Life Support System", quantity: 1, purpose: "Provide oxygen/water from lunar resources" },
      { name: "3D Printer (Lunar Materials)", quantity: 2, purpose: "Manufacture parts from lunar regolith" },
      { name: "Fuel Production Unit", quantity: 1, purpose: "Produce fuel from lunar water/oxygen" },
      { name: "Waste Recycling System", quantity: 1, purpose: "Recycle waste into useful resources" },
      { name: "ISRU Control Center", quantity: 1, purpose: "Monitor and optimize ISRU operations" }
    ]

    equipment.each do |item|
      puts "  ✓ #{item[:quantity]}x #{item[:name]} - #{item[:purpose]}"
    end

    puts "✓ Life support/manufacturing equipment loaded - all systems ISRU-based"
  end

  def load_isru_expansion_equipment(craft)
    puts "Loading expansion equipment (manufactured on-site where possible)..."

    equipment = [
      { name: "ISRU Manufacturing Plant", quantity: 1, purpose: "Scale up lunar material processing" },
      { name: "Additional Habitat Modules", quantity: 3, purpose: "Expand living space using ISRU materials" },
      { name: "Resource Export System", quantity: 1, purpose: "Prepare lunar resources for export" },
      { name: "Advanced ISRU Systems", quantity: 2, purpose: "Enhanced resource extraction capabilities" }
    ]

    equipment.each do |item|
      puts "  ✓ #{item[:quantity]}x #{item[:name]} - #{item[:purpose]}"
    end

    puts "✓ Expansion equipment loaded - most components manufactured from lunar resources"
  end

  def load_isru_research_equipment(craft)
    puts "Loading research equipment (ISRU-manufactured where possible)..."

    equipment = [
      { name: "Research Laboratory", quantity: 1, purpose: "Conduct lunar science experiments" },
      { name: "ISRU Technology Lab", quantity: 1, purpose: "Develop advanced ISRU methods" },
      { name: "Resource Analysis Suite", quantity: 1, purpose: "Analyze lunar resource composition" },
      { name: "Export Processing Facility", quantity: 1, purpose: "Process resources for Earth export" }
    ]

    equipment.each do |item|
      puts "  ✓ #{item[:quantity]}x #{item[:name]} - #{item[:purpose]}"
    end

    puts "✓ Research equipment loaded - base now focuses on ISRU technology and resource export"
  end

  # ISRU Construction Execution Methods
  def execute_isru_habitat_construction(settlement)
    puts "Executing ISRU-assisted habitat construction..."

    construction_jobs = [
      "Pour regolith-based foundation using ISRU materials",
      "Construct habitat shell with lunar concrete",
      "Install pressurization system using ISRU gases",
      "Complete interior using 3D-printed components"
    ]

    construction_jobs.each do |job|
      puts "  ✓ #{job}"
    end

    puts "✓ Habitat construction complete - 70% materials from lunar ISRU"
  end

  def execute_isru_life_support_expansion(settlement)
    puts "Executing ISRU-based life support expansion..."

    life_support_phases = [
      "Install ISRU oxygen generation system",
      "Deploy water extraction and recycling",
      "Set up fuel production from lunar resources",
      "Integrate waste-to-resource conversion"
    ]

    life_support_phases.each do |phase|
      puts "  ✓ #{phase}"
    end

    puts "✓ Life support fully operational - 100% resources from lunar ISRU"
  end

  def execute_isru_expansion(settlement)
    puts "Executing ISRU-driven base expansion..."

    expansion_phases = [
      "Construct additional habitat modules using ISRU concrete",
      "Expand ISRU production capacity",
      "Build resource storage and export facilities",
      "Establish self-sufficient manufacturing"
    ]

    expansion_phases.each do |phase|
      puts "  ✓ #{phase}"
    end

    puts "✓ Base expansion complete - producing resource surplus for export"
  end

  def execute_isru_research_operations(settlement)
    puts "Executing research and export operations..."

    research_activities = [
      "Establish lunar science research program",
      "Develop advanced ISRU extraction techniques",
      "Analyze resource export economics",
      "Test autonomous ISRU systems"
    ]

    research_activities.each do |activity|
      puts "  ✓ #{activity}"
    end

    puts "✓ Research operational - base becomes lunar resource export hub"
  end

  # ISRU Final Status Display
  def display_isru_final_status
    puts "\n🎯 === ISRU-FOCUSED LUNAR BASE CONSTRUCTION COMPLETE ==="
    puts "Total Missions: #{@total_missions} | Total Launches: #{@total_launches}"
    puts "Construction Timeline: 12 months (2025-07-01 to 2026-07-01)"
    puts ""

    puts "📊 ISRU PRODUCTION METRICS:"
    puts "  🌬️  Oxygen Production: #{@isru_metrics[:oxygen_produced]} kg/month"
    puts "  💧 Water Production: #{@isru_metrics[:water_produced]} kg/month"
    puts "  ⛽ Fuel Production: #{@isru_metrics[:fuel_produced]} kg/month"
    puts "  📉 Earth Imports Reduced: #{@isru_metrics[:earth_imports_reduced]}%"
    puts ""

    puts "🏆 MISSION TIMELINE SUMMARY:"
    @mission_timeline.each do |mission|
      puts "  Mission #{mission[:mission]}: #{mission[:name]}"
      puts "    📅 #{mission[:launch_date]} → #{mission[:completion_date]}"
      puts "    👥 Population: #{mission[:settlement_population]} | Status: #{mission[:operational_status]}"
      puts "    🎯 ISRU Priority: #{mission[:isru_priority]}"
      puts ""
    end

    puts "✅ SUCCESS: Lunar base established with ISRU as primary resource strategy"
    puts "   - All basic resources (oxygen, water) produced locally"
    puts "   - Construction materials sourced from lunar regolith"
    puts "   - Fuel production enables expansion and export"
    puts "   - Minimal Earth dependency achieved within 12 months"
    puts "   - Base becomes self-sustaining lunar resource hub"
  end
end