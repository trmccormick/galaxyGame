# frozen_string_literal: true

# Prompt Compiler / Builder — walks the five-layer dependency chain and produces
# a FROZEN renderer-neutral prompt with provenance header.
#
# This is Layer 3 of the asset generation pipeline:
#   Profile Resolution → Composition Refinery → Prompt Compilation
#
# Responsibilities:
# - Walk five-layer dependency chain via direct file paths (development-time tooling)
# - Validate required fields per layer, resolve IDs
# - Substitute composed sections into Render Template variables
# - Produce FROZEN prompt with provenance header
# - Never treat reference images as authoritative geometry
#
# Configuration: None. This component is deterministic and data-driven.
# All experimental mechanisms are handled by the Composition Refinery.

module AssetGeneration
  class PromptCompiler
    # Error raised when required fields are missing or IDs cannot be resolved
    class CompilationError < StandardError; end

    # Compile a FROZEN prompt from canonical data through the five-layer chain.
    #
    # @param asset_id [String] Canonical asset identifier
    # @param blueprint_path [Pathname, String] Path to the Blueprint JSON file
    # @param operational_data_path [Pathname, String] Path to the Operational Data JSON file (optional)
    # @param visual_definition_path [Pathname, String] Path to the Visual Definition JSON file
    # @param render_template_path [Pathname, String] Path to the Render Template markdown file
    # @param targeted_refinements_config [Hash] Optional refinements config (disabled by default)
    # @param safeguards_config [Hash] Optional safeguards config (disabled by default)
    # @return [Hash] Compilation result with keys:
    #   - prompt_text: The FROZEN prompt text with provenance header
    #   - provenance: Hash of provenance metadata
    #   - validation_errors: Array of error messages (empty if compilation succeeded)
    #   - validation_warnings: Array of warning messages
    # @raise [CompilationError] if required fields are missing or IDs cannot be resolved
    def self.compile(asset_id:, blueprint_path:, visual_definition_path:, render_template_path:,
                     operational_data_path: nil,
                     targeted_refinements_config: nil, safeguards_config: nil)
      new(
        asset_id: asset_id,
        blueprint_path: Pathname.new(blueprint_path),
        operational_data_path: operational_data_path ? Pathname.new(operational_data_path) : nil,
        visual_definition_path: Pathname.new(visual_definition_path),
        render_template_path: Pathname.new(render_template_path),
        targeted_refinements_config: targeted_refinements_config || { enabled: false },
        safeguards_config: safeguards_config || { enabled: false }
      ).run
    end

    attr_reader :asset_id, :blueprint_path, :operational_data_path,
                :visual_definition_path, :render_template_path,
                :targeted_refinements_config, :safeguards_config

    def initialize(asset_id:, blueprint_path:, operational_data_path:, visual_definition_path:,
                   render_template_path:, targeted_refinements_config:, safeguards_config:)
      @asset_id = asset_id
      @blueprint_path = Pathname.new(blueprint_path)
      @operational_data_path = operational_data_path
      @visual_definition_path = Pathname.new(visual_definition_path)
      @render_template_path = Pathname.new(render_template_path)
      @targeted_refinements_config = targeted_refinements_config
      @safeguards_config = safeguards_config
    end

    # Run the full compilation pipeline.
    #
    # @return [Hash] Compilation result
    def run
      validation_errors = []
      validation_warnings = []

      # Step 1: Load canonical data from direct file paths
      blueprint_entry = load_blueprint(validation_errors, validation_warnings)
      return build_error_result(validation_errors) if validation_errors.any?

      operational_entry = load_operational_data(blueprint_entry, validation_errors, validation_warnings)
      return build_error_result(validation_errors) if validation_errors.any?

      visual_definition = load_visual_definition(validation_errors, validation_warnings)
      return build_error_result(validation_errors) if validation_errors.any?

      # Step 2: Profile Resolution (Layer 1)
      profile_attributes = resolve_profiles(blueprint_entry, visual_definition, validation_errors, validation_warnings)
      return build_error_result(validation_errors) if validation_errors.any?

      # Step 3: Composition Refinery (Layer 2)
      composed_sections = compose_sections(profile_attributes, visual_definition, blueprint_entry, operational_entry, validation_warnings)

      # Step 4: Prompt Compilation (Layer 3)
      prompt_text = compile_prompt(composed_sections, profile_attributes)

      # Step 5: Build provenance header
      provenance = build_provenance(blueprint_entry, visual_definition, profile_attributes)

      {
        prompt_text: prompt_text,
        provenance: provenance,
        validation_errors: validation_errors,
        validation_warnings: validation_warnings
      }
    end

    private

    # Load blueprint data from direct file path.
    #
    # @return [Hash] Blueprint entry data
    def load_blueprint(validation_errors, validation_warnings)
      unless blueprint_path.exist?
        validation_errors << "Blueprint for asset '#{asset_id}' not found at #{blueprint_path}"
        return nil
      end

      content = blueprint_path.read
      begin
        blueprint_data = JSON.parse(content)
      rescue JSON::ParserError => e
        validation_errors << "Failed to parse Blueprint at #{blueprint_path}: #{e.message}"
        return nil
      end

      validate_blueprint(blueprint_data, validation_errors, validation_warnings)
      blueprint_data
    end

    # Load operational data from direct file path or use blueprint fallback.
    #
    # @return [Hash] Operational data entry
    def load_operational_data(blueprint_entry, validation_errors, validation_warnings)
      return {} unless operational_data_path&.exist?

      content = operational_data_path.read
      begin
        JSON.parse(content)
      rescue JSON::ParserError => e
        validation_warnings << "Failed to parse Operational Data at #{operational_data_path}: #{e.message}"
        {}
      end
    end

    # Load Visual Definition file from direct path.
    #
    # @return [Hash] Visual Definition data
    def load_visual_definition(validation_errors, validation_warnings)
      return nil unless visual_definition_path.exist?

      content = visual_definition_path.read
      begin
        JSON.parse(content)
      rescue JSON::ParserError => e
        validation_errors << "Failed to parse Visual Definition at #{visual_definition_path}: #{e.message}"
        nil
      end
    end

    # Resolve profiles via ProfileResolutionEngine.
    #
    # @return [Hash] Structured profile attributes
    def resolve_profiles(blueprint_entry, visual_definition, validation_errors, validation_warnings)
      vd = extract_visual_definition_data(visual_definition)

      # Extract blueprint data for cross-validation
      bp_tech = blueprint_entry[:technology_level]
      bp_mfg = blueprint_entry[:manufacturing_style]

      # Get visual_profile ID from blueprint
      vp_id = blueprint_entry[:visual_profile]
      if vp_id.nil? || vp_id.to_s.empty?
        validation_errors << "Blueprint for asset '#{asset_id}' does not specify a visual_profile"
        return nil
      end

      ProfileResolutionEngine.resolve(
        visual_profile_id: vp_id.to_s,
        blueprint_data: { technology_level: bp_tech, manufacturing_style: bp_mfg },
        visual_definition_data: { technology_level: vd[:technology_level], manufacturing_style: vd[:manufacturing_style] },
        render_template_path: render_template_path
      )
    end

    # Compose prompt sections via CompositionRefinery.
    #
    # @return [Hash] Composed prompt sections
    def compose_sections(profile_attributes, visual_definition, blueprint_entry, operational_entry, validation_warnings)
      vd = extract_visual_definition_data(visual_definition)

      CompositionRefinery.compose(
        profile_attributes: profile_attributes,
        visual_definition: vd,
        blueprint_data: blueprint_entry,
        operational_data: operational_entry,
        targeted_refinements: targeted_refinements_config,
        safeguards: safeguards_config
      )
    end

    # Compile the final prompt text from composed sections and Render Template.
    #
    # @return [String] The FROZEN prompt text with provenance header
    def compile_prompt(composed_sections, profile_attributes)
      sections = composed_sections[:sections] || {}
      render_template_content = load_render_template

      # Build the prompt following the hierarchy from RH-006 experiments:
      # CAMERA before STYLE, DESIGN CONSTRAINTS before recognition features, tiered features

      prompt_lines = []

      # Provenance header (YAML frontmatter)
      prompt_lines << "# Generated Prompt — Provenance Header"

      # SUBJECT section
      if sections[:subject].present?
        prompt_lines << ""
        prompt_lines << "SUBJECT:"
        prompt_lines << sections[:subject]
      end

      # CAMERA section (high-priority rendering constraint)
      render_req = sections[:render_requirements] || {}
      if render_req.is_a?(Hash) && render_req[:camera].present?
        prompt_lines << ""
        prompt_lines << "CAMERA (high-priority rendering constraint — overrides all default camera conventions):"
        prompt_lines << "- #{render_req[:camera]} — directly above, looking straight down, no perspective distortion"
        prompt_lines << "- NO side views, NO three-quarter angles, NO isometric perspectives"
        prompt_lines << "- This camera angle is mandatory for this asset"
      end

      # PROPORTIONS section
      proportions = sections[:proportions] || {}
      if proportions.is_a?(Hash) && proportions[:canonical_dimensions].present?
        dims = proportions[:canonical_dimensions]
        prompt_lines << ""
        prompt_lines << "PROPORTIONS (visual anchors — canonical dimensions: length #{dims[:length_m]}m, width #{dims[:width_m]}m, height #{dims[:height_m]}m):"
        if proportions[:visual_anchors].is_a?(Array)
          proportions[:visual_anchors].each do |anchor|
            prompt_lines << "- #{anchor}"
          end
        end
      end

      # STYLE section (resolved from profile, not inlined prose)
      style = sections[:style] || {}
      if style.is_a?(Hash) && style[:profile_id].present?
        prompt_lines << ""
        prompt_lines << "STYLE (resolved from #{style[:profile_id]} profile):"
        if style[:materials].is_a?(Array) && style[:materials].any?
          prompt_lines << "- Materials: #{style[:materials].join(', ')}"
        end
        prompt_lines << "- Finish: #{style[:finish]}" if style[:finish].present?
        prompt_lines << "- Aesthetic: #{style[:aesthetic]}" if style[:aesthetic].present?
      end

      # MANUFACTURING section (resolved from profile, not inlined prose)
      mfg = sections[:manufacturing] || {}
      if mfg.is_a?(Hash) && mfg[:profile_id].present?
        prompt_lines << ""
        prompt_lines << "MANUFACTURING (resolved from #{mfg[:profile_id]} profile):"
        prompt_lines << "- #{mfg[:method]}" if mfg[:method].present?
        prompt_lines << "- Quality: #{mfg[:quality]}" if mfg[:quality].present?
        if mfg[:excluded].is_a?(Array) && mfg[:excluded].any?
          prompt_lines << "- Excluded: #{mfg[:excluded].join(', ')}"
        end
      end

      # TECHNOLOGY LEVEL section (resolved from profile, not inlined prose)
      tl = sections[:technology_level] || {}
      if tl.is_a?(Hash) && tl[:profile_id].present?
        prompt_lines << ""
        prompt_lines << "TECHNOLOGY LEVEL (resolved from #{tl[:profile_id]} profile):"
        prompt_lines << "- Mk#{tl[:level]} characteristics: #{tl[:characteristics].join(', ')}" if tl[:characteristics].is_a?(Array) && tl[:characteristics].any?
        if tl[:excluded].is_a?(Array) && tl[:excluded].any?
          prompt_lines << "- Excluded: #{tl[:excluded].join(', ')}"
        end
      end

      # DESIGN CONSTRAINTS section (before recognition features)
      constraints = sections[:design_constraints]
      if constraints.is_a?(Array) && constraints.any?
        prompt_lines << ""
        prompt_lines << "DESIGN CONSTRAINTS (non-negotiable):"
        constraints.each do |constraint|
          prompt_lines << "- #{constraint}"
        end
      end

      # MARKINGS section
      markings = sections[:markings] || {}
      if markings.is_a?(Hash) && markings[:hazard_striping].present?
        hs = markings[:hazard_striping]
        prompt_lines << ""
        prompt_lines << "MARKINGS:"
        if hs.is_a?(Hash) && hs[:colors].is_a?(Array)
          hs[:colors].each do |color|
            prompt_lines << "- #{color}"
          end
        end
        prompt_lines << "- Application: #{hs[:application]}" if hs[:application].present?
      end

      # RECOGNITION FEATURES section (ordered by priority tier)
      features = sections[:recognition_features] || {}
      if features.is_a?(Hash)
        prompt_lines << ""
        prompt_lines << "RECOGNITION FEATURES (ordered by priority tier from Visual Definition visual_priority):"

        if features[:primary].is_a?(Array) && features[:primary].any?
          prompt_lines << ""
          prompt_lines << "PRIMARY (must be dominant in the render):"
          features[:primary].each_with_index do |feature, idx|
            prompt_lines << "#{idx + 1}. #{feature}"
          end
        end

        if features[:secondary].is_a?(Array) && features[:secondary].any?
          prompt_lines << ""
          prompt_lines << "SECONDARY (must be clearly visible):"
          start_idx = features[:primary]&.size || 0
          features[:secondary].each_with_index do |feature, idx|
            prompt_lines << "#{start_idx + idx + 1}. #{feature}"
          end
        end

        if features[:tertiary].is_a?(Array) && features[:tertiary].any?
          prompt_lines << ""
          prompt_lines << "TERTIARY (should be present and visible upon closer inspection):"
          start_idx = ((features[:primary]&.size || 0) + (features[:secondary]&.size || 0))
          features[:tertiary].each_with_index do |feature, idx|
            prompt_lines << "#{start_idx + idx + 1}. #{feature}"
          end
        end
      end

      # RENDER REQUIREMENTS section
      if render_req.is_a?(Hash) && render_req[:lighting].present?
        prompt_lines << ""
        prompt_lines << "RENDER REQUIREMENTS:"
        prompt_lines << "- Single vehicle or object only, fully visible, no cropping"
        prompt_lines << "- #{render_req[:camera]} camera view" if render_req[:camera].present?
        prompt_lines << "- Vehicle centered within the canvas, occupying approximately #{render_req[:framing]}" if render_req[:framing].present?
        prompt_lines << "- #{render_req[:lighting]} illumination" if render_req[:lighting].present?
        prompt_lines << "- Physically accurate materials"
        prompt_lines << "- Strong, immediately recognizable silhouette"
      end

      # BACKGROUND section
      bg = sections[:background] || {}
      if bg.is_a?(Hash) && bg[:background_type].present?
        prompt_lines << ""
        prompt_lines << "BACKGROUND:"
        prompt_lines << "- #{bg[:background_type]}"
        if bg[:prohibitions].is_a?(Array) && bg[:prohibitions].any?
          prompt_lines << "- No #{bg[:prohibitions].join(", no ")}"
        end
      end

      # OUTPUT section
      output = sections[:output] || {}
      if output.is_a?(Hash)
        prompt_lines << ""
        prompt_lines << "OUTPUT:"
        prompt_lines << "- #{output[:format]}" if output[:format].present?
        prompt_lines << "- #{output[:dimensions]}" if output[:dimensions].present?
        prompt_lines << "- #{output[:quality]}" if output[:quality].present?
      end

      # Append FROZEN status
      prompt_lines << ""
      prompt_lines << "---"
      prompt_lines << ""
      prompt_lines << "**FROZEN STATUS** — Do not modify after initial generation run."

      prompt_lines.join("\n")
    end

    # Build the provenance header metadata.
    #
    # @return [Hash] Provenance metadata
    def build_provenance(blueprint_entry, visual_definition, profile_attributes)
      vd = extract_visual_definition_data(visual_definition)
      style = profile_attributes[:global_visual_style] || {}

      {
        asset_id: asset_id,
        blueprint_version: blueprint_entry[:metadata]&.dig(:version) || "unknown",
        visual_profile: style[:profile_id] || "unknown",
        visual_definition_asset_id: vd[:asset_id] || "unknown",
        render_template: render_template_path.basename(".md").to_s,
        composition_method: "profile_composition_v1",
        targeted_refinements: targeted_refinements_config[:enabled] ? "enabled" : "none",
        safeguards: safeguards_config[:enabled] ? "enabled" : "none",
        generated_at: Time.now.iso8601,
        prompt_version: 1,
        status: "FROZEN"
      }
    end

    # Load the Render Template content.
    #
    # @return [String] The Render Template markdown content
    def load_render_template
      render_template_path.read
    end

    # Validate blueprint data for required fields.
    #
    # @param bp_data [Hash] Blueprint data to validate
    # @param validation_errors [Array<String>] Errors array to append to
    # @param validation_warnings [Array<String>] Warnings array to append to
    def validate_blueprint(bp_data, validation_errors, validation_warnings)
      return if bp_data.empty?

      required_fields = [:id, :asset_family]
      required_fields.each do |field|
        if bp_data[field].nil? || bp_data[field].to_s.empty?
          validation_errors << "Blueprint for asset '#{asset_id}' is missing required field: #{field}"
        end
      end

      # Warn if visual_profile is missing (will be caught later)
      if bp_data[:visual_profile].nil? || bp_data[:visual_profile].to_s.empty?
        validation_warnings << "Blueprint for asset '#{asset_id}' does not specify a visual_profile"
      end
    end

    # Extract the inner visual_definition data from the wrapper.
    # Visual Definition files may contain {"visual_definition": {...}} wrapper.
    #
    # @param visual_definition [Hash] The parsed Visual Definition file content
    # @return [Hash] The inner visual_definition data
    def extract_visual_definition_data(visual_definition)
      vd = visual_definition || {}

      if vd.is_a?(Hash) && vd.key?(:visual_definition) && vd[:visual_definition].is_a?(Hash)
        vd[:visual_definition]
      elsif vd.is_a?(Hash) && vd.key?("visual_definition") && vd["visual_definition"].is_a?(Hash)
        vd["visual_definition"]
      else
        vd.is_a?(Hash) ? vd : {}
      end
    end

    # Build an error result when compilation fails.
    #
    # @return [Hash] Error result with empty prompt_text
    def build_error_result(validation_errors)
      {
        prompt_text: "",
        provenance: {},
        validation_errors: validation_errors,
        validation_warnings: []
      }
    end
  end
end
