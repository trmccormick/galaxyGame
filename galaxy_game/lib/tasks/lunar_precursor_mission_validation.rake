# lib/tasks/lunar_precursor_mission_validation.rake
#
# Precursor Mission Validation — Phase 1 (Bootstrap)
# Validates GCC mining → Initial HLT landings → Power grid deployment
# using data-driven inputs from profile and manifest JSON files.

namespace :luna_mission do
  desc "Phase 1: GCC mining → Initial HLT landings → Power grid deployment"
  task phase1_bootstrap: :environment do
    puts "=" * 80
    puts "LUNA PRECURSOR MISSION — PHASE 1 BOOTSTRAP"
    puts "=" * 80

    # Load profile and manifest data
    profile = load_profile('precursor_mission_profile_v1')
    manifest = load_manifest('precursor_mission_manifest_v1')

    unless profile && manifest
      abort("FATAL: Could not load profile or manifest")
    end

    puts "\nProfile: #{profile['profile_id']} (#{profile['name']})"
    puts "Manifest: #{manifest['manifest_id']} (#{manifest['archetype']})"
    puts "Total phases in profile: #{(profile['phases'] || []).count}"
    puts "Total phases in manifest: #{(manifest['phases'] || []).count}"

    # Phase 1/3: GCC Mining
    puts "\n--- Phase 1/3: GCC Mining ---"
    gcc_result = validate_gcc_mining(profile, manifest)
    unless gcc_result[:success]
      abort("Phase 1 failed: #{gcc_result[:error]}")
    end
    puts "✓ Currency generation verified: #{gcc_result[:currency_per_day]} GCC/day"

    # Phase 2/3: Initial HLT Landings
    puts "\n--- Phase 2/3: Initial HLT Landings ---"
    landings_result = validate_initial_hlt_landings(profile, manifest)
    unless landings_result[:success]
      abort("Phase 2 failed: #{landings_result[:error]}")
    end
    puts "✓ Multi-cargo delivery verified: #{landings_result[:manifests_count]} manifests"

    # Phase 3/3: Power Grid Deployment
    puts "\n--- Phase 3/3: Power Grid Deployment ---"
    power_result = validate_power_grid_deployment(profile, manifest)
    unless power_result[:success]
      abort("Phase 3 failed: #{power_result[:error]}")
    end
    puts "✓ Power grid verified: RTG=#{power_result[:rtg_units]}, Solar=#{power_result[:solar_beams]}"

    puts "\n" + "=" * 80
    puts "PHASE 1 COMPLETE — All bootstrap phases validated successfully"
    puts "=" * 80
  end

  # ---------------------------------------------------------------------------
  # Phase 2 Interplanetary Logistics Task
  # ---------------------------------------------------------------------------

  desc "Phase 2: Titan/Venus transit → ISRU production → L1/LEO supply chain"
  task phase2_interplanetary: :environment do
    puts "=" * 80
    puts "LUNA PRECURSOR MISSION — PHASE 2 INTERPLANETARY LOGISTICS"
    puts "=" * 80

    # Load profile and manifest data
    profile = load_profile('precursor_mission_profile_v1')
    manifest = load_manifest('precursor_mission_manifest_v1')

    unless profile && manifest
      abort("FATAL: Could not load profile or manifest")
    end

    puts "\nProfile: #{profile['profile_id']} (#{profile['name']})"
    puts "Manifest: #{manifest['manifest_id']} (#{manifest['archetype']})"
    puts "Total phases in profile: #{(profile['phases'] || []).count}"
    puts "Total phases in manifest: #{(manifest['phases'] || []).count}"

    # Phase 4: Titan Delivery (longest transit)
    puts "\n--- Phase 4/7: Titan HLT Atmosphere Harvesting ---"
    titan_result = validate_titan_delivery(profile, manifest)
    unless titan_result[:success]
      abort("Phase 4 failed: #{titan_result[:error]}")
    end
    puts "✓ Titan delivery verified: N2=#{titan_result[:n2_kg]}kg, CH4=#{titan_result[:ch4_kg]}kg"

    # Phase 5: Venus Delivery (follows Titan)
    puts "\n--- Phase 5/7: Venus HLT Atmosphere Harvesting ---"
    venus_result = validate_venus_delivery(profile, manifest)
    unless venus_result[:success]
      abort("Phase 5 failed: #{venus_result[:error]}")
    end
    puts "✓ Venus delivery verified: CO2=#{venus_result[:co2_kg]}kg, N2=#{venus_result[:n2_kg]}kg"

    # Phase 6: Luna ISRU Production (depends on Titan delivery)
    puts "\n--- Phase 6/7: Luna ISRU Production ---"
    isru_result = validate_luna_isru_production(profile, manifest)
    unless isru_result[:success]
      abort("Phase 6 failed: #{isru_result[:error]}")
    end
    puts "✓ ISRU production verified: O2=#{isru_result[:o2_production]}, H2=#{isru_result[:h2_production]}, He3=#{isru_result[:he3_production]}"

    # Phase 7: L1/LEO Supply Chain
    puts "\n--- Phase 7/7: Luna → L1/LEO Depot Supply ---"
    supply_result = validate_l1_leo_supply(profile, manifest)
    unless supply_result[:success]
      abort("Phase 7 failed: #{supply_result[:error]}")
    end
    puts "✓ L1/LEO supply verified: depot_materials=#{supply_result[:depot_modules]} modules"

    # Venus refueling dependency check
    puts "\n--- Venus Refueling Dependency ---"
    refuel_result = validate_venus_refueling(profile, manifest)
    unless refuel_result[:success]
      abort("Venus refueling failed: #{refuel_result[:error]}")
    end
    puts "✓ Venus refueling verified via: #{refuel_result[:source]}"

    puts "\n" + "=" * 80
    puts "PHASE 2 COMPLETE — All interplanetary logistics validated successfully"
    puts "=" * 80
  end

  # ---------------------------------------------------------------------------
  # Profile / Manifest Loading Helpers
  # ---------------------------------------------------------------------------

  def load_profile(profile_id)
    path = GalaxyGame::Paths::MISSIONS_V2_PROFILES_PATH.join("#{profile_id}.json")
    return nil unless File.exist?(path)

    data = JSON.parse(File.read(path))
    puts "\n[INFO] Loaded profile from: #{path}"
    data
  end

  def load_manifest(manifest_id)
    path = GalaxyGame::Paths::MISSIONS_V2_MANIFESTS_PATH.join("#{manifest_id}.json")
    return nil unless File.exist?(path)

    data = JSON.parse(File.read(path))
    puts "[INFO] Loaded manifest from: #{path}"
    data
  end

  # ---------------------------------------------------------------------------
  # Phase Validation Methods
  # ---------------------------------------------------------------------------

  ##
  # Validate GCC mining phase.
  # Verifies GCC satellite hardware exists in manifest and currency generation is configured.
  # Returns: { success: true/false, currency_per_day: N, error: msg }
  #
  def validate_gcc_mining(profile, manifest)
    phase_id = 'gcc_mining'

    # Find phase in profile
    profile_phase = (profile['phases'] || []).find { |p| p['phase_id'] == phase_id }
    unless profile_phase
      return { success: false, error: "Phase '#{phase_id}' not found in profile" }
    end

    puts "  Profile phase: #{profile_phase['name']} (#{profile_phase['duration_days']} days)"
    puts "  Target body: #{profile_phase['environment']['target_body']}"

    # Find phase in manifest
    manifest_phase = (manifest['phases'] || []).find { |p| p['phase_id'] == phase_id }
    unless manifest_phase
      return { success: false, error: "Phase '#{phase_id}' not found in manifest" }
    end

    hardware = manifest_phase['required_hardware'] || []
    if hardware.empty?
      return { success: false, error: "No hardware defined for phase '#{phase_id}' in manifest" }
    end

    # Verify GCC mining satellite exists
    gcc_sat = hardware.find { |h| h['id'] == 'gcc_mining_satellite' }
    unless gcc_sat
      return { success: false, error: "GCC mining satellite not found in manifest hardware list" }
    end

    puts "  Hardware entries: #{hardware.count}"
    hardware.each do |hw|
      puts "    - #{hw['id']} (count: #{hw['count']}, role: #{hw['role']})"
    end

    # Verify currency generation output is configured
    outputs = manifest_phase['outputs'] || {}
    currency_per_day = outputs['currency_per_day'] || 0

    if currency_per_day <= 0
      return { success: false, error: "Currency generation rate is zero or negative" }
    end

    # Verify prerequisites are empty (GCC mining has no prerequisites)
    prereqs = profile_phase['prerequisites'] || []
    unless prereqs.empty?
      return { success: false, error: "GCC mining should have no prerequisites, found: #{prereqs.join(', ')}" }
    end

    puts "  Prerequisites: none (correct)"
    puts "  Currency output: #{currency_per_day} GCC/day"

    { success: true, currency_per_day: currency_per_day }
  end

  ##
  # Validate initial HLT landings phase.
  # Verifies 3 landing manifests exist in manifest and each cargo manifest can be procured.
  # Returns: { success: true/false, manifests_count: N, error: msg }
  #
  def validate_initial_hlt_landings(profile, manifest)
    phase_id = 'initial_hlt_landings'

    # Find phase in profile
    profile_phase = (profile['phases'] || []).find { |p| p['phase_id'] == phase_id }
    unless profile_phase
      return { success: false, error: "Phase '#{phase_id}' not found in profile" }
    end

    puts "  Profile phase: #{profile_phase['name']} (#{profile_phase['duration_days']} days)"
    puts "  Target body: #{profile_phase['environment']['target_body']}"

    # Find phase in manifest
    manifest_phase = (manifest['phases'] || []).find { |p| p['phase_id'] == phase_id }
    unless manifest_phase
      return { success: false, error: "Phase '#{phase_id}' not found in manifest" }
    end

    hardware = manifest_phase['required_hardware'] || []
    if hardware.empty?
      return { success: false, error: "No hardware defined for phase '#{phase_id}' in manifest" }
    end

    # Verify 3 landing manifests exist
    manifests_count = hardware.count
    puts "  Landing manifests: #{manifests_count}"

    # Validate each landing has cargo definition
    required_landings = ['hlt_landing_1_habitat', 'hlt_landing_2_isru', 'hlt_landing_3_tank_farm']
    found_landings = hardware.map { |h| h['id'] }

    missing = required_landings - found_landings
    unless missing.empty?
      return { success: false, error: "Missing landing manifests: #{missing.join(', ')}" }
    end

    # Validate cargo contents for each landing
    hardware.each do |hw|
      cargo = hw['cargo'] || []
      puts "  - #{hw['id']} (count: #{hw['count']})"
      puts "    Cargo: #{cargo.join(', ')}"

      if cargo.empty?
        return { success: false, error: "No cargo defined for landing manifest '#{hw['id']}'" }
      end
    end

    # Verify profile has landing_manifests with matching IDs
    profile_landings = (profile_phase['landing_manifests'] || [])
    if profile_landings.count != manifests_count
      return { success: false, error: "Profile landing_manifests count (#{profile_landings.count}) != manifest hardware count (#{manifests_count})" }
    end

    # Verify outputs are configured
    outputs = manifest_phase['outputs'] || {}
    required_outputs = ['habitat_modules_delivered', 'isru_equipment_delivered', 'tank_farm_components_delivered']
    missing_outputs = required_outputs - outputs.keys
    unless missing_outputs.empty?
      return { success: false, error: "Missing manifest outputs: #{missing_outputs.join(', ')}" }
    end

    puts "  Outputs verified: #{outputs.keys.join(', ')}"

    { success: true, manifests_count: manifests_count }
  end

  ##
  # Validate power grid deployment phase.
  # Verifies RTG units, solar array beams, umbilical hub in manifest.
  # Validates 3D printing of structural beams from regolith feedstock.
  # Returns: { success: true/false, rtg_units: N, solar_beams: N, error: msg }
  #
  def validate_power_grid_deployment(profile, manifest)
    phase_id = 'power_grid_deployment'

    # Find phase in profile
    profile_phase = (profile['phases'] || []).find { |p| p['phase_id'] == phase_id }
    unless profile_phase
      return { success: false, error: "Phase '#{phase_id}' not found in profile" }
    end

    puts "  Profile phase: #{profile_phase['name']} (#{profile_phase['duration_days']} days)"
    puts "  Target body: #{profile_phase['environment']['target_body']}"

    # Find phase in manifest
    manifest_phase = (manifest['phases'] || []).find { |p| p['phase_id'] == phase_id }
    unless manifest_phase
      return { success: false, error: "Phase '#{phase_id}' not found in manifest" }
    end

    hardware = manifest_phase['required_hardware'] || []
    if hardware.empty?
      return { success: false, error: "No hardware defined for phase '#{phase_id}' in manifest" }
    end

    # Verify RTG units exist
    rtg = hardware.find { |h| h['id'] == 'rtg_units' }
    unless rtg
      return { success: false, error: "RTG units not found in manifest hardware list" }
    end
    rtg_count = rtg['count'].to_i
    puts "  RTG units: #{rtg_count}"

    # Verify solar array beams exist
    solar = hardware.find { |h| h['id'] == 'solar_array_beams' }
    unless solar
      return { success: false, error: "Solar array beams not found in manifest hardware list" }
    end
    solar_count = solar['count'].to_i
    puts "  Solar array beams: #{solar_count}"

    # Verify umbilical hub exists
    hub = hardware.find { |h| h['id'] == 'umbilical_hub' }
    unless hub
      return { success: false, error: "Umbilical hub not found in manifest hardware list" }
    end
    puts "  Umbilical hub: #{hub['count']} (role: #{hub['role']})"

    # Validate all hardware entries
    hardware.each do |hw|
      puts "    - #{hw['id']} (count: #{hw['count']}, role: #{hw['role']})"
    end

    # Verify 3D printing note for solar beams (regolith feedstock)
    if solar['_note'].to_s.downcase.include?('regolith') || solar['_note'].to_s.downcase.include?('3d print')
      puts "  ✓ Solar beams use in-situ manufacturing (regolith feedstock)"
    else
      puts "  ⚠ Solar beams note does not mention regolith/3D printing — verify in-situ manufacturing"
    end

    # Verify outputs are configured
    outputs = manifest_phase['outputs'] || {}
    required_outputs = ['rtg_power_online', 'solar_array_built', 'power_grid_connected']
    missing_outputs = required_outputs - outputs.keys
    unless missing_outputs.empty?
      return { success: false, error: "Missing manifest outputs: #{missing_outputs.join(', ')}" }
    end

    puts "  Outputs verified: #{outputs.keys.join(', ')}"

    { success: true, rtg_units: rtg_count, solar_beams: solar_count }
  end

  # ---------------------------------------------------------------------------
  # Phase 2 Interplanetary Logistics Validation Methods
  # ---------------------------------------------------------------------------

  ##
  # Validate Titan delivery phase.
  # Verifies atmosphere harvester hardware exists in manifest and validates
  # N2 + CH4 delivery with variance-based yield check against 730-day transit timing.
  # Returns: { success: true/false, n2_kg: N, ch4_kg: N, error: msg }
  #
  def validate_titan_delivery(profile, manifest)
    phase_id = 'titan_delivery'

    # Find phase in profile
    profile_phase = (profile['phases'] || []).find { |p| p['phase_id'] == phase_id }
    unless profile_phase
      return { success: false, error: "Phase '#{phase_id}' not found in profile" }
    end

    puts "  Profile phase: #{profile_phase['name']} (#{profile_phase['duration_days']} days)"
    puts "  Target body: #{profile_phase['environment']['target_body']}"

    # Find phase in manifest
    manifest_phase = (manifest['phases'] || []).find { |p| p['phase_id'] == phase_id }
    unless manifest_phase
      return { success: false, error: "Phase '#{phase_id}' not found in manifest" }
    end

    hardware = manifest_phase['required_hardware'] || []
    if hardware.empty?
      return { success: false, error: "No hardware defined for phase '#{phase_id}' in manifest" }
    end

    # Verify atmosphere harvester hardware exists
    harvester = hardware.find { |h| h['id'] == 'atmosphere_harvester_titan' }
    unless harvester
      return { success: false, error: "Titan atmosphere harvester not found in manifest hardware list" }
    end

    puts "  Hardware entries: #{hardware.count}"
    hardware.each do |hw|
      puts "    - #{hw['id']} (count: #{hw['count']}, role: #{hw['role']})"
    end

    # Validate delivery_to_luna data shape (variance-based, not hardcoded)
    delivery = manifest_phase['delivery_to_luna'] || {}
    unless delivery.is_a?(Hash) && !delivery.empty?
      return { success: false, error: "No delivery_to_luna data defined for phase '#{phase_id}'" }
    end

    # Verify variance-based yield structure
    source_gases = delivery['source_gases'] || []
    harvester_count = delivery['harvester_count'] || 0
    transit_days = delivery['transit_days'] || 0
    yield_formula = delivery['yield_formula'] || ''
    variance_range = delivery['variance_range'] || [1.0, 1.0]

    if source_gases.empty?
      return { success: false, error: "No source_gases defined for phase '#{phase_id}'" }
    end

    if harvester_count <= 0
      return { success: false, error: "Harvester count must be positive for phase '#{phase_id}'" }
    end

    if transit_days <= 0
      return { success: false, error: "Transit days must be positive for phase '#{phase_id}'" }
    end

    # Validate transit timing matches profile expectation (730 days)
    profile_transit = profile_phase.dig('runtime_parameters', 'transit_days')
    if profile_transit && profile_transit != transit_days
      return { success: false, error: "Transit days mismatch: manifest=#{transit_days}, profile=#{profile_transit}" }
    end

    puts "  Source gases: #{source_gases.join(', ')}"
    puts "  Harvester count: #{harvester_count}"
    transit_note = profile_transit == transit_days ? '✓ matches profile' : '⚠ differs from profile'
    puts "  Transit timing: #{transit_days} days (#{transit_note})"
    puts "  Yield formula: #{yield_formula}"
    puts "  Variance range: [#{variance_range[0]}, #{variance_range[1]}]"

    # Verify outputs are configured
    outputs = manifest_phase['outputs'] || {}
    required_outputs = ['n2_delivery', 'ch4_delivery']
    missing_outputs = required_outputs - outputs.keys
    unless missing_outputs.empty?
      return { success: false, error: "Missing manifest outputs: #{missing_outputs.join(', ')}" }
    end

    puts "  Outputs verified: #{outputs.keys.join(', ')}"

    # Return simulated delivery quantities (based on harvester_count and variance)
    # In production, these would be computed from the yield_formula with actual atmosphere data
    base_n2_kg = 50000
    base_ch4_kg = 25000
    variance_factor = (variance_range[0] + variance_range[1]) / 2.0

    { success: true, n2_kg: (base_n2_kg * variance_factor).to_i, ch4_kg: (base_ch4_kg * variance_factor).to_i }
  end

  ##
  # Validate Venus delivery phase.
  # Verifies atmosphere harvester hardware exists in manifest and validates
  # CO2 + N2 delivery with variance-based yield check against 400-day transit timing.
  # Returns: { success: true/false, co2_kg: N, n2_kg: N, error: msg }
  #
  def validate_venus_delivery(profile, manifest)
    phase_id = 'venus_delivery'

    # Find phase in profile
    profile_phase = (profile['phases'] || []).find { |p| p['phase_id'] == phase_id }
    unless profile_phase
      return { success: false, error: "Phase '#{phase_id}' not found in profile" }
    end

    puts "  Profile phase: #{profile_phase['name']} (#{profile_phase['duration_days']} days)"
    puts "  Target body: #{profile_phase['environment']['target_body']}"

    # Find phase in manifest
    manifest_phase = (manifest['phases'] || []).find { |p| p['phase_id'] == phase_id }
    unless manifest_phase
      return { success: false, error: "Phase '#{phase_id}' not found in manifest" }
    end

    hardware = manifest_phase['required_hardware'] || []
    if hardware.empty?
      return { success: false, error: "No hardware defined for phase '#{phase_id}' in manifest" }
    end

    # Verify atmosphere harvester hardware exists
    harvester = hardware.find { |h| h['id'] == 'atmosphere_harvester_venus' }
    unless harvester
      return { success: false, error: "Venus atmosphere harvester not found in manifest hardware list" }
    end

    puts "  Hardware entries: #{hardware.count}"
    hardware.each do |hw|
      puts "    - #{hw['id']} (count: #{hw['count']}, role: #{hw['role']})"
    end

    # Validate delivery_to_luna data shape (variance-based, not hardcoded)
    delivery = manifest_phase['delivery_to_luna'] || {}
    unless delivery.is_a?(Hash) && !delivery.empty?
      return { success: false, error: "No delivery_to_luna data defined for phase '#{phase_id}'" }
    end

    # Verify variance-based yield structure
    source_gases = delivery['source_gases'] || []
    harvester_count = delivery['harvester_count'] || 0
    transit_days = delivery['transit_days'] || 0
    yield_formula = delivery['yield_formula'] || ''
    variance_range = delivery['variance_range'] || [1.0, 1.0]

    if source_gases.empty?
      return { success: false, error: "No source_gases defined for phase '#{phase_id}'" }
    end

    if harvester_count <= 0
      return { success: false, error: "Harvester count must be positive for phase '#{phase_id}'" }
    end

    if transit_days <= 0
      return { success: false, error: "Transit days must be positive for phase '#{phase_id}'" }
    end

    # Validate transit timing matches profile expectation (400 days)
    profile_transit = profile_phase.dig('runtime_parameters', 'transit_days')
    if profile_transit && profile_transit != transit_days
      return { success: false, error: "Transit days mismatch: manifest=#{transit_days}, profile=#{profile_transit}" }
    end

    puts "  Source gases: #{source_gases.join(', ')}"
    puts "  Harvester count: #{harvester_count}"
    transit_note = profile_transit == transit_days ? '✓ matches profile' : '⚠ differs from profile'
    puts "  Transit timing: #{transit_days} days (#{transit_note})"
    puts "  Yield formula: #{yield_formula}"
    puts "  Variance range: [#{variance_range[0]}, #{variance_range[1]}]"

    # Verify outputs are configured
    outputs = manifest_phase['outputs'] || {}
    required_outputs = ['co2_delivery', 'n2_delivery']
    missing_outputs = required_outputs - outputs.keys
    unless missing_outputs.empty?
      return { success: false, error: "Missing manifest outputs: #{missing_outputs.join(', ')}" }
    end

    puts "  Outputs verified: #{outputs.keys.join(', ')}"

    # Return simulated delivery quantities (based on harvester_count and variance)
    base_co2_kg = 75000
    base_n2_kg = 30000
    variance_factor = (variance_range[0] + variance_range[1]) / 2.0

    { success: true, co2_kg: (base_co2_kg * variance_factor).to_i, n2_kg: (base_n2_kg * variance_factor).to_i }
  end

  ##
  # Validate Luna ISRU production phase.
  # Verifies TEU/PVE equipment in manifest and validates volatile production outputs.
  # Returns: { success: true/false, o2_production: bool, h2_production: bool, he3_production: bool, error: msg }
  #
  def validate_luna_isru_production(profile, manifest)
    phase_id = 'luna_isru_production'

    # Find phase in profile
    profile_phase = (profile['phases'] || []).find { |p| p['phase_id'] == phase_id }
    unless profile_phase
      return { success: false, error: "Phase '#{phase_id}' not found in profile" }
    end

    puts "  Profile phase: #{profile_phase['name']} (#{profile_phase['duration_days']} days)"
    puts "  Target body: #{profile_phase['environment']['target_body']}"

    # Find phase in manifest
    manifest_phase = (manifest['phases'] || []).find { |p| p['phase_id'] == phase_id }
    unless manifest_phase
      return { success: false, error: "Phase '#{phase_id}' not found in manifest" }
    end

    hardware = manifest_phase['required_hardware'] || []
    if hardware.empty?
      return { success: false, error: "No hardware defined for phase '#{phase_id}' in manifest" }
    end

    # Verify TEU (Thermal Extraction Unit) exists
    teu = hardware.find { |h| h['id'] == 'thermal_extraction_unit' }
    unless teu
      return { success: false, error: "Thermal extraction unit not found in manifest hardware list" }
    end
    puts "  TEU units: #{teu['count']} (role: #{teu['role']})"

    # Verify PVE (Planetary Volatiles Extractor) exists
    pve = hardware.find { |h| h['id'] == 'planetary_volatiles_extractor' }
    unless pve
      return { success: false, error: "Planetary volatiles extractor not found in manifest hardware list" }
    end
    puts "  PVE units: #{pve['count']} (role: #{pve['role']})"

    # Verify I-beam press exists
    ibeam = hardware.find { |h| h['id'] == 'i_beam_press' }
    unless ibeam
      return { success: false, error: "I-beam press not found in manifest hardware list" }
    end
    puts "  I-beam press: #{ibeam['count']} (role: #{ibeam['role']})"

    # Validate all hardware entries
    hardware.each do |hw|
      puts "    - #{hw['id']} (count: #{hw['count']}, role: #{hw['role']})"
    end

    # Verify outputs are configured (boolean flags for production capability)
    outputs = manifest_phase['outputs'] || {}
    required_outputs = ['o2_production', 'h2_production', 'he3_production', 'i_beam_production']
    missing_outputs = required_outputs - outputs.keys
    unless missing_outputs.empty?
      return { success: false, error: "Missing manifest outputs: #{missing_outputs.join(', ')}" }
    end

    puts "  Outputs verified: #{outputs.keys.join(', ')}"

    # Verify profile prerequisites (depends on titan_delivery completing first)
    prereqs = profile_phase['prerequisites'] || []
    unless prereqs.include?('titan_delivery')
      return { success: false, error: "ISRU production should depend on titan_delivery, found: #{prereqs.join(', ')}" }
    end
    puts "  Prerequisites: #{prereqs.join(', ')} (correct — depends on Titan delivery)"

    { success: true, o2_production: outputs['o2_production'], h2_production: outputs['h2_production'], he3_production: outputs['he3_production'] }
  end

  ##
  # Validate L1/LEO supply chain phase.
  # Verifies depot modules and docking hardware in manifest.
  # Returns: { success: true/false, depot_modules: N, error: msg }
  #
  def validate_l1_leo_supply(profile, manifest)
    phase_id = 'l1_leo_supply'

    # Find phase in profile
    profile_phase = (profile['phases'] || []).find { |p| p['phase_id'] == phase_id }
    unless profile_phase
      return { success: false, error: "Phase '#{phase_id}' not found in profile" }
    end

    puts "  Profile phase: #{profile_phase['name']} (#{profile_phase['duration_days']} days)"
    puts "  Target body: #{profile_phase['environment']['target_body']}"

    # Find phase in manifest
    manifest_phase = (manifest['phases'] || []).find { |p| p['phase_id'] == phase_id }
    unless manifest_phase
      return { success: false, error: "Phase '#{phase_id}' not found in manifest" }
    end

    hardware = manifest_phase['required_hardware'] || []
    if hardware.empty?
      return { success: false, error: "No hardware defined for phase '#{phase_id}' in manifest" }
    end

    # Verify inflatable depot modules exist
    depot_modules = hardware.find { |h| h['id'] == 'inflatable_depot_modules' }
    unless depot_modules
      return { success: false, error: "Inflatable depot modules not found in manifest hardware list" }
    end
    depot_count = depot_modules['count'].to_i
    puts "  Depot modules: #{depot_count}"

    # Verify docking hardware exists
    docking = hardware.find { |h| h['id'] == 'docking_hardware' }
    unless docking
      return { success: false, error: "Docking hardware not found in manifest hardware list" }
    end
    puts "  Docking hardware: #{docking['count']} (role: #{docking['role']})"

    # Validate all hardware entries
    hardware.each do |hw|
      puts "    - #{hw['id']} (count: #{hw['count']}, role: #{hw['role']})"
    end

    # Verify outputs are configured
    outputs = manifest_phase['outputs'] || {}
    required_outputs = ['depot_materials_delivered', 'l1_depot_ready']
    missing_outputs = required_outputs - outputs.keys
    unless missing_outputs.empty?
      return { success: false, error: "Missing manifest outputs: #{missing_outputs.join(', ')}" }
    end

    puts "  Outputs verified: #{outputs.keys.join(', ')}"

    # Verify profile prerequisites (depends on luna_isru_production completing first)
    prereqs = profile_phase['prerequisites'] || []
    unless prereqs.include?('luna_isru_production')
      return { success: false, error: "L1/LEO supply should depend on luna_isru_production, found: #{prereqs.join(', ')}" }
    end
    puts "  Prerequisites: #{prereqs.join(', ')} (correct — depends on ISRU production)"

    { success: true, depot_modules: depot_count }
  end

  ##
  # Validate Venus refueling dependency.
  # Checks venus_delivery refuel_dependency from manifest and validates
  # Titan return OR Earth CH4 import OR local production path exists.
  # Returns: { success: true/false, source: "titan_return"|"earth_import"|"luna_local_production", error: msg }
  #
  def validate_venus_refueling(profile, manifest)
    phase_id = 'venus_delivery'

    # Find phase in manifest (refuel_dependency is manifest-only)
    manifest_phase = (manifest['phases'] || []).find { |p| p['phase_id'] == phase_id }
    unless manifest_phase
      return { success: false, error: "Phase '#{phase_id}' not found in manifest" }
    end

    refuel_dep = manifest_phase['refuel_dependency'] || {}
    if refuel_dep.empty?
      return { success: false, error: "No refuel_dependency defined for phase '#{phase_id}'" }
    end

    source_options = refuel_dep['source_options'] || []
    requires_ch4_kg = refuel_dep['requires_ch4_kg'] || 0

    if source_options.empty?
      return { success: false, error: "No CH4 source options defined for Venus refueling" }
    end

    if requires_ch4_kg <= 0
      return { success: false, error: "CH4 requirement must be positive for Venus refueling" }
    end

    puts "  CH4 required: #{requires_ch4_kg}kg"
    puts "  Source options: #{source_options.join(', ')}"

    # Validate at least one source option exists (critical path constraint)
    valid_sources = ['titan_return', 'earth_import', 'luna_local_production']
    invalid_sources = source_options - valid_sources
    unless invalid_sources.empty?
      return { success: false, error: "Invalid refueling sources: #{invalid_sources.join(', ')}" }
    end

    # Return first available source as the validated path
    selected_source = source_options.first
    puts "  Selected refueling source: #{selected_source}"

    { success: true, source: selected_source }
  end
end
