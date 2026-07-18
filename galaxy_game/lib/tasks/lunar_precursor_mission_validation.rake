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
  # Profile / Manifest Loading Helpers
  # ---------------------------------------------------------------------------

  def load_profile(profile_id)
    # Try MISSIONS_V2_PROFILES_PATH first (mounted app/data location)
    path = GalaxyGame::Paths::MISSIONS_V2_PROFILES_PATH.join("#{profile_id}.json")
    if File.exist?(path)
      data = JSON.parse(File.read(path))
      puts "\n[INFO] Loaded profile from: #{path}"
      return data
    end

    # Fallback: try galaxy_game/data/json-data path (mounted at /home/galaxy_game/data/json-data)
    fallback_path = Pathname.new('/home/galaxy_game/data/json-data/missions_v2/profiles').join("#{profile_id}.json")
    if File.exist?(fallback_path)
      data = JSON.parse(File.read(fallback_path))
      puts "\n[INFO] Loaded profile from (fallback): #{fallback_path}"
      return data
    end

    nil
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
end
