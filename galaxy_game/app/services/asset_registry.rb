# frozen_string_literal: true

# AssetRegistry/orchestration service — development-time asset identity and path resolution
# 
# This service implements the B1 approved design for mapping canonical game data
# to development-time visual artifacts. It owns:
# - asset_id as primary lookup key (shared across all artifacts)
# - asset_id → artifact path resolution (blueprint, operational_data, visual_definition, render_template)
# - asset_id → visual_profile_id association (resolved by orchestration)
# - Representation manifest (development-time metadata about which representations exist/are missing)
#
# Critical boundaries:
# - Blueprint does NOT own visual fields — registry owns asset_id → visual_profile_id
# - PromptCompiler receives already-resolved inputs, does NOT search repository by asset_id
# - Asset-generation tooling is development-time infrastructure outside Rails runtime
# - No artifact searches the repository by asset_id

class AssetRegistry
  # Valid asset_family values from Visual Definition template
  VALID_ASSET_FAMILIES = %w[resource component assembly equipment unit structure vehicle organization].freeze

  # Representation manifest status values
  VALID_REPRESENTATION_STATUSES = %w[exists missing experimental planned].freeze

  # RH-400 concrete example — used for testing and reference
  RH400_BLUEPRINT_ID = 'regolith_harvester_rover'
  RH400_ASSET_ID = 'VEHICLE_HARVESTER_ROVER_RH400'
  RH400_FILE_PREFIX = 'rh400_'

  # Render profiles from Visual Definition template
  RENDER_PROFILES = %w[
    inventory_icon
    catalog_render
    engineering_render
    blueprint
    exploded_view
    sprite_sheet
  ].freeze

  # Initialize with optional base paths (defaults to GalaxyGame::Paths)
  def initialize(blueprints_path: nil, operational_data_path: nil, visual_definitions_path: nil, render_templates_path: nil)
    @blueprints_path = blueprints_path || GalaxyGame::Paths::BLUEPRINTS_PATH
    @operational_data_path = operational_data_path || GalaxyGame::Paths::JSON_DATA.join('operational_data')
    @visual_definitions_path = visual_definitions_path || Rails.root.join('docs', 'reference', 'asset-generation', 'visual_definitions')
    @render_templates_path = render_templates_path || Rails.root.join('docs', 'reference', 'asset-generation', 'render_templates')
    @registry_cache = {}
  end

  # Resolve asset by asset_id — returns AssetRegistryEntry hash or nil
  def resolve(asset_id)
    return nil unless asset_id.present?

    # Check cache first
    return @registry_cache[asset_id] if @registry_cache.key?(asset_id)

    # Try to find in registry (populated on demand from known assets)
    entry = find_in_registry(asset_id)
    return entry if entry

    # Auto-discover from filesystem if asset exists in blueprints/visual_definitions
    entry = discover_from_filesystem(asset_id)
    @registry_cache[asset_id] = entry if entry

    entry
  end

  # Get representation manifest for an asset — returns hash of render_profile → status info
  def representation_manifest(asset_id)
    entry = resolve(asset_id)
    return {} unless entry

    entry[:representations] || {}
  end

  # Check if a representation exists for an asset
  def representation_exists?(asset_id, render_profile)
    manifest = representation_manifest(asset_id)
    status = manifest.dig(render_profile, :status)
    status == 'exists'
  end

  # Get catalog manifest path for runtime bridge (pre-computed paths to catalog assets)
  def catalog_manifest_path(asset_id)
    entry = resolve(asset_id)
    return nil unless entry
    entry[:catalog_manifest_path]
  end

  # Get surface manifest path for runtime bridge (pre-computed paths to surface sprites)
  def surface_manifest_path(asset_id)
    entry = resolve(asset_id)
    return nil unless entry
    entry[:surface_manifest_path]
  end

  # Get visual_profile_id association (resolved by orchestration, stored in registry)
  def visual_profile_id(asset_id)
    entry = resolve(asset_id)
    return nil unless entry
    entry[:visual_profile_id]
  end

  # Register an asset in the registry — called by development-time orchestration
  def register_asset(asset_id:, blueprint_id:, asset_family:, component_class: nil, file_prefix: nil,
                     visual_profile_id: nil, representations: {}, catalog_manifest_path: nil, surface_manifest_path: nil)
    validate_asset_family(asset_family)

    entry = {
      asset_id: asset_id,
      blueprint_id: blueprint_id,
      asset_family: asset_family,
      component_class: component_class,
      file_prefix: file_prefix,
      blueprint_path: find_blueprint_path(blueprint_id),
      operational_data_path: find_operational_data_path(blueprint_id),
      visual_definition_path: find_visual_definition_path(asset_id),
      render_template_path: find_render_template_path(asset_family),
      visual_profile_id: visual_profile_id,
      representations: normalize_representations(representations),
      catalog_manifest_path: catalog_manifest_path,
      surface_manifest_path: surface_manifest_path,
      created_at: Time.current,
      updated_at: Time.current
    }

    @registry_cache[asset_id] = entry
    entry
  end

  # Get all registered assets — returns array of entries
  def all_assets
    @registry_cache.values
  end

  # Get assets filtered by asset_family
  def assets_by_family(asset_family)
    @registry_cache.values.select { |e| e[:asset_family] == asset_family.to_s }
  end

  # Check if an asset is registered
  def asset_registered?(asset_id)
    @registry_cache.key?(asset_id)
  end

  # Resolve Visual Profile for a given asset_id.
  # 
  # This is the development-time orchestration boundary: AssetRegistry owns
  # asset_id → visual_profile_id association and provides resolution via
  # ProfileResolutionEngine. PromptCompiler receives already-resolved profile
  # attributes — it does NOT discover or search for profiles by asset_id.
  #
  # Note: ProfileResolutionEngine lives in tools/asset_generation/ (outside Rails).
  # This method returns the raw VP ID for orchestration to resolve externally.
  # The actual file loading happens in development-time tooling, not at runtime.
  #
  # @param asset_id [String] The canonical asset identifier
  # @return [Hash, nil] Hash with :visual_profile_id and :entry keys, or nil if no VP registered
  def resolve_visual_profile(asset_id)
    entry = resolve(asset_id)
    return nil unless entry

    vp_id = entry[:visual_profile_id]
    return nil if vp_id.nil? || vp_id.to_s.empty?

    {
      visual_profile_id: vp_id.to_s,
      entry: entry,
      resolved_at: Time.current
    }
  end

  # Check if an asset has a registered Visual Profile (regardless of file existence)
  def has_visual_profile?(asset_id)
    entry = resolve(asset_id)
    return false unless entry

    vp_id = entry[:visual_profile_id]
    !vp_id.nil? && !vp_id.to_s.empty?
  end

  # Get RH-400 entry (concrete example for testing)
  def rh400_entry
    resolve(RH400_ASSET_ID)
  end

  # Validate that an asset_family is valid
  def valid_asset_families
    VALID_ASSET_FAMILIES
  end

  # Get all defined render profiles
  def render_profiles
    RENDER_PROFILES
  end

  private

  # Find entry in registry cache by asset_id
  def find_in_registry(asset_id)
    @registry_cache[asset_id]
  end

  # Auto-discover asset from filesystem — builds entry from existing files
  def discover_from_filesystem(asset_id)
    # Look for visual definition file
    vd_path = find_visual_definition_path(asset_id)
    return nil unless vd_path

    # Extract blueprint_id from visual definition or filename
    blueprint_id = extract_blueprint_id_from_visual_definition(vd_path) || infer_blueprint_id(asset_id)

    # Build minimal entry from discovered files
    {
      asset_id: asset_id,
      blueprint_id: blueprint_id,
      asset_family: extract_asset_family(vd_path),
      component_class: extract_component_class(vd_path),
      file_prefix: infer_file_prefix(asset_id),
      blueprint_path: find_blueprint_path(blueprint_id),
      operational_data_path: find_operational_data_path(blueprint_id),
      visual_definition_path: vd_path,
      render_template_path: find_render_template_path(extract_asset_family(vd_path)),
      visual_profile_id: nil, # Will be resolved by orchestration
      representations: build_representation_manifest(asset_id, vd_path),
      catalog_manifest_path: nil, # Generated by development-time orchestration
      surface_manifest_path: nil, # Generated by development-time orchestration
      created_at: Time.current,
      updated_at: Time.current
    }
  end

  # Find blueprint path for a given blueprint_id
  def find_blueprint_path(blueprint_id)
    return nil unless blueprint_id.present?

    # Try exact match first
    candidate = @blueprints_path.join("#{blueprint_id}.json")
    return candidate.to_s if candidate.exist?

    # Try with _bp suffix
    candidate = @blueprints_path.join("#{blueprint_id}_bp.json")
    return candidate.to_s if candidate.exist?

    # Search recursively
    Dir.glob(@blueprints_path.join('**/*.json')).find do |f|
      File.basename(f, '.json').sub(/_bp$/, '') == blueprint_id
    end&.to_s
  end

  # Find operational data path for a given blueprint_id
  def find_operational_data_path(blueprint_id)
    return nil unless blueprint_id.present?

    base = File.basename(blueprint_id, '.json').sub(/_bp$/, '')
    
    # Try exact match
    candidate = @operational_data_path.join("#{base}.json")
    return candidate.to_s if candidate.exist?

    # Search recursively
    Dir.glob(@operational_data_path.join('**/*.json')).find do |f|
      File.basename(f, '.json').sub(/_data$/, '').sub(/_bp$/, '') == base ||
        File.basename(f, '.json').start_with?(base)
    end&.to_s
  end

  # Find visual definition path for a given asset_id
  def find_visual_definition_path(asset_id)
    return nil unless asset_id.present?

    # Try exact match
    candidate = @visual_definitions_path.join("#{asset_id}.json")
    return candidate.to_s if candidate.exist?

    # Try .md extension (some visual definitions may be markdown)
    candidate = @visual_definitions_path.join("#{asset_id}.md")
    return candidate.to_s if candidate.exist?

    # Search recursively for files containing this asset_id
    Dir.glob(@visual_definitions_path.join('**/*')).find do |f|
      next unless File.file?(f)
      
      begin
        content = File.read(f)
        # Check if file contains the asset_id as a field
        content.include?("asset_id") && content.include?(asset_id)
      rescue => e
        Rails.logger.warn("AssetRegistry: Error reading #{f}: #{e.message}")
        nil
      end
    end&.to_s
  end

  # Find render template path for a given asset_family
  def find_render_template_path(asset_family)
    return nil unless asset_family.present?

    candidate = @render_templates_path.join("#{asset_family}.json")
    return candidate.to_s if candidate.exist?

    candidate = @render_templates_path.join("#{asset_family}.md")
    return candidate.to_s if candidate.exist?

    nil
  end

  # Extract blueprint_id from visual definition file
  def extract_blueprint_id_from_visual_definition(vd_path)
    return nil unless vd_path && File.exist?(vd_path)

    begin
      content = File.read(vd_path)
      # Try JSON parse first
      data = JSON.parse(content)
      return data['blueprint_id'] if data.is_a?(Hash) && data['blueprint_id'].present?
    rescue => e
      # Not JSON, try to extract from markdown or other format
      Rails.logger.debug("AssetRegistry: Visual definition #{vd_path} is not JSON")
    end

    nil
  end

  # Infer blueprint_id from asset_id using naming conventions
  def infer_blueprint_id(asset_id)
    # Convert VEHICLE_HARVESTER_ROVER_RH400 → regolith_harvester_rover
    # This is a heuristic — orchestration should provide explicit mappings
    return RH400_BLUEPRINT_ID if asset_id == RH400_ASSET_ID

    # Generic conversion: lowercase, replace underscores with spaces, capitalize words, join
    asset_id.downcase.gsub(/_[A-Z]/) { |m| "_#{m[-1]}" }.gsub('_', ' ').split.map(&:capitalize).join(' ').downcase.gsub(' ', '_')
  end

  # Extract asset_family from visual definition file
  def extract_asset_family(vd_path)
    return nil unless vd_path && File.exist?(vd_path)

    begin
      content = File.read(vd_path)
      data = JSON.parse(content)
      return data['asset_family'] if data.is_a?(Hash) && data['asset_family'].present?
    rescue => e
      # Not JSON, try to extract from markdown or other format
      Rails.logger.debug("AssetRegistry: Visual definition #{vd_path} is not JSON")
    end

    nil
  end

  # Extract component_class from visual definition file
  def extract_component_class(vd_path)
    return nil unless vd_path && File.exist?(vd_path)

    begin
      content = File.read(vd_path)
      data = JSON.parse(content)
      return data['component_class'] if data.is_a?(Hash) && data['component_class'].present?
    rescue => e
      Rails.logger.debug("AssetRegistry: Visual definition #{vd_path} is not JSON")
    end

    nil
  end

  # Infer file_prefix from asset_id using naming conventions
  def infer_file_prefix(asset_id)
    return RH400_FILE_PREFIX if asset_id == RH400_ASSET_ID

    # Generic: take first letter of each word, lowercase
    asset_id.scan(/[A-Z][a-z]+/).map(&:first).join('_').downcase + '_'
  end

  # Build representation manifest from visual definition and filesystem
  def build_representation_manifest(asset_id, vd_path)
    manifest = {}

    # Get render_profiles from visual definition
    render_profiles = get_render_profiles_from_visual_definition(vd_path)
    render_profiles ||= RENDER_PROFILES # Default to all profiles if not specified

    # Check each profile against filesystem
    render_profiles.each do |profile|
      status = determine_representation_status(asset_id, profile)
      manifest[profile] = {
        status: status,
        files: find_representation_files(asset_id, profile),
        complexity_levels: [], # Will be populated by orchestration
        notes: status == 'experimental' ? 'Test asset — not production' : nil
      }
    end

    manifest
  end

  # Get render_profiles from visual definition file
  def get_render_profiles_from_visual_definition(vd_path)
    return nil unless vd_path && File.exist?(vd_path)

    begin
      content = File.read(vd_path)
      data = JSON.parse(content)
      return data['render_profiles'] if data.is_a?(Hash) && data['render_profiles'].is_a?(Array)
    rescue => e
      Rails.logger.debug("AssetRegistry: Visual definition #{vd_path} is not JSON")
    end

    nil
  end

  # Determine representation status by checking filesystem
  def determine_representation_status(asset_id, profile)
    files = find_representation_files(asset_id, profile)
    return 'missing' if files.empty?

    # Check if any file is experimental
    files.any? { |f| f.to_s.include?('_test') || f.to_s.include?('_experimental') } ? 'experimental' : 'exists'
  end

  # Find representation files for a given profile
  def find_representation_files(asset_id, profile)
    return [] unless asset_id.present? && profile.present?

    prefix = infer_file_prefix(asset_id)
    catalog_images_dir = GalaxyGame::Paths::JSON_DATA.join('images', 'catalog')
    
    case profile
    when 'catalog_render'
      Dir.glob(catalog_images_dir.join("**/#{prefix}*concept*.png")).to_a +
        Dir.glob(catalog_images_dir.join("**/#{prefix}*regolith*.png")).to_a +
        Dir.glob(catalog_images_dir.join("**/#{prefix}*catalog*.png")).to_a
    when 'sprite_sheet'
      Dir.glob(catalog_images_dir.join("**/#{prefix}*sprite*.png")).to_a
    when 'inventory_icon'
      Dir.glob(catalog_images_dir.join("**/#{prefix}*icon*.png")).to_a
    when 'engineering_render'
      Dir.glob(catalog_images_dir.join("**/#{prefix}*engineering*.png")).to_a
    when 'blueprint'
      Dir.glob(catalog_images_dir.join("**/#{prefix}*blueprint*.png")).to_a
    when 'exploded_view'
      Dir.glob(catalog_images_dir.join("**/#{prefix}*exploded*.png")).to_a
    else
      []
    end
  end

  # Normalize representation hash — ensure all required fields present
  def normalize_representations(representations)
    normalized = {}
    
    representations.each do |profile, info|
      status = info.is_a?(Hash) ? info[:status] || info['status'] : info
      next unless VALID_REPRESENTATION_STATUSES.include?(status.to_s)

      normalized[profile] = {
        status: status.to_s,
        files: info.is_a?(Hash) ? (info[:files] || info['files'] || []) : [],
        complexity_levels: info.is_a?(Hash) ? (info[:complexity_levels] || info['complexity_levels'] || []) : [],
        notes: info.is_a?(Hash) ? (info[:notes] || info['notes'] || nil) : nil
      }
    end

    normalized
  end

  # Validate asset_family is in valid list
  def validate_asset_family(asset_family)
    return if VALID_ASSET_FAMILIES.include?(asset_family.to_s)
    raise ArgumentError, "Invalid asset_family: #{asset_family}. Must be one of: #{VALID_ASSET_FAMILIES.join(', ')}"
  end

  # Custom error for Visual Profile resolution failures
  class ProfileResolutionError < StandardError; end

  private

  # Find entry in registry cache by asset_id
  def find_in_registry(asset_id)
    @registry_cache[asset_id]
  end
end
