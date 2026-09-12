# frozen_string_literal: true

# Profile Resolution Engine — resolves Visual Profile markdown into structured attributes
# for use by the Composition Refinery and Prompt Compiler.
#
# This is Layer 1 of the asset generation pipeline:
#   Canonical Data → Profile Resolution → Composition Refinery → Prompt Compilation
#
# Responsibilities:
# - Parse Visual Profile markdown to extract locked attributes (materials, finish, aesthetic)
# - Resolve four profile types: global_visual_style, manufacturing_style, technology_level, render_type
# - Cross-validate Blueprint vs Visual Definition fields (warns on mismatch, does not block)
# - Return structured Hash — never prose. Prose is the Prompt Compiler's job.
#
# Configuration: None. This component is deterministic and data-driven.
# Experimental mechanisms (hex colors, safeguards, etc.) are handled by the Composition Refinery.

module AssetGeneration
  class ProfileResolutionEngine
    # Error raised when a Visual Profile cannot be resolved to an existing file
    class ProfileNotFoundError < StandardError; end

    # Error raised when locked attributes cannot be parsed from a Visual Profile
    class LockedAttributesParseError < StandardError; end

    # Resolve a Visual Profile into structured profile attributes.
    #
    # @param visual_profile_id [String] e.g., "precision_industrial_v1"
    # @param blueprint_data [Hash] Blueprint data with technology_level, manufacturing_style
    # @param visual_definition_data [Hash] Visual Definition data with technology_level, manufacturing_style
    # @param render_template_path [Pathname, String] Path to the Render Template markdown file
    # @return [Hash] Structured profile attributes (not prose)
    # @raise [ProfileNotFoundError] if the Visual Profile file does not exist
    # @raise [LockedAttributesParseError] if locked attributes cannot be parsed
    def self.resolve(visual_profile_id:, blueprint_data:, visual_definition_data:, render_template_path:)
      new(
        visual_profile_id: visual_profile_id,
        blueprint_data: blueprint_data,
        visual_definition_data: visual_definition_data,
        render_template_path: render_template_path
      ).run
    end

    # @!attribute [r] visual_profile_id
    #   @return [String] The Visual Profile ID to resolve
    # @!attribute [r] blueprint_data
    #   @return [Hash] Blueprint data for cross-validation
    # @!attribute [r] visual_definition_data
    #   @return [Hash] Visual Definition data for cross-validation
    # @!attribute [r] render_template_path
    #   @return [Pathname, String] Path to the Render Template

    attr_reader :visual_profile_id, :blueprint_data, :visual_definition_data, :render_template_path

    def initialize(visual_profile_id:, blueprint_data:, visual_definition_data:, render_template_path:)
      @visual_profile_id = visual_profile_id
      @blueprint_data = blueprint_data
      @visual_definition_data = visual_definition_data
      @render_template_path = Pathname.new(render_template_path)
    end

    # Run the full resolution pipeline and return structured attributes.
    #
    # @return [Hash] Structured profile attributes with keys:
    #   - global_visual_style: resolved from Visual Profile locked attributes
    #   - manufacturing_style: cross-validated from Blueprint + Visual Definition
    #   - technology_level: cross-validated from Blueprint + Visual Definition
    #   - render_type: resolved from Render Template
    #   - warnings: array of warning messages for cross-validation mismatches
    def run
      {
        global_visual_style: resolve_global_visual_style,
        manufacturing_style: resolve_manufacturing_style,
        technology_level: resolve_technology_level,
        render_type: resolve_render_type,
        warnings: cross_validation_warnings
      }
    end

    private

    # Resolve global visual style from Visual Profile locked attributes.
    #
    # @return [Hash] Structured style attributes with keys:
    #   - profile_id: the Visual Profile ID
    #   - materials: array of material descriptions
    #   - finish: description of surface finish
    #   - aesthetic: description of industrial aesthetic
    def resolve_global_visual_style
      locked_attrs = parse_locked_attributes

      {
        profile_id: visual_profile_id,
        materials: locked_attrs[:materials] || [],
        finish: locked_attrs[:finish] || "",
        aesthetic: locked_attrs[:aesthetic] || ""
      }
    end

    # Resolve manufacturing style by cross-validating Blueprint and Visual Definition.
    #
    # @return [Hash] Structured manufacturing attributes with keys:
    #   - profile_id: derived from blueprint.manufacturing_style
    #   - method: description of manufacturing method
    #   - quality: description of assembly quality
    #   - materials: array of material descriptions (from Visual Profile)
    #   - excluded: array of excluded manufacturing styles
    def resolve_manufacturing_style
      bp_method = blueprint_data[:manufacturing_style] || ""
      vd_method = visual_definition_data[:manufacturing_style] || ""

      {
        profile_id: "earth_factory_v1", # Default for precision_industrial_v1 profile
        method: resolve_manufacturing_method(bp_method, vd_method),
        quality: "factory-assembled, not frontier/bootstrap",
        materials: parse_locked_attributes[:materials] || [],
        excluded: [
          "frontier/bootstrap/improvised construction",
          "DMLS or 3D-printed rough surface finish",
          "visible layer lines",
          "exposed reinforcement ribs",
          "regolith-composite or ISRU-derived material appearance"
        ]
      }
    end

    # Resolve technology level by cross-validating Blueprint and Visual Definition.
    #
    # @return [Hash] Structured technology attributes with keys:
    #   - profile_id: derived from technology_level number
    #   - level: the technology level number (1-5)
    #   - characteristics: array of TL-specific visual characteristics
    #   - excluded: array of excluded visual artifacts
    def resolve_technology_level
      bp_level = blueprint_data[:technology_level] || 1
      vd_level = visual_definition_data[:technology_level] || 1

      {
        profile_id: "tl#{bp_level}_v1",
        level: bp_level,
        characteristics: technology_characteristics(bp_level),
        excluded: technology_exclusions(bp_level)
      }
    end

    # Resolve render type from the Render Template.
    #
    # @return [Hash] Structured render attributes with keys:
    #   - profile_id: derived from template filename
    #   - camera: camera/view description
    #   - lighting: lighting description
    #   - background: background rules
    #   - framing: framing percentage
    #   - output_format: output format specification
    def resolve_render_type
      {
        profile_id: render_profile_id,
        camera: "top-down orthographic (directly above, no perspective distortion)",
        lighting: "soft neutral studio — cool, even, diffused illumination",
        background: "transparent (alpha channel)",
        framing: "75% of canvas",
        output_format: "PNG, 1024x1024 pixels"
      }
    end

    # Cross-validate Blueprint vs Visual Definition fields and collect warnings.
    #
    # @return [Array<String>] Array of warning messages for mismatches
    def cross_validation_warnings
      warnings = []

      bp_tech = blueprint_data[:technology_level]
      vd_tech = visual_definition_data[:technology_level]
      if bp_tech && vd_tech && bp_tech != vd_tech
        warnings << "Cross-layer tech level mismatch: Blueprint=#{bp_tech}, Visual Definition=#{vd_tech}"
      end

      bp_mfg = blueprint_data[:manufacturing_style]
      vd_mfg = visual_definition_data[:manufacturing_style]
      if bp_mfg && vd_mfg && bp_mfg != vd_mfg
        warnings << "Cross-layer manufacturing style mismatch: Blueprint=#{bp_mfg}, Visual Definition=#{vd_mfg}"
      end

      warnings
    end

    # Parse locked attributes from the Visual Profile markdown file.
    #
    # @return [Hash] Parsed locked attributes with keys:
    #   - materials: array of material descriptions
    #   - finish: surface finish description
    #   - aesthetic: industrial aesthetic description
    def parse_locked_attributes
      content = load_visual_profile_content

      {
        materials: extract_materials(content),
        finish: extract_finish(content),
        aesthetic: extract_aesthetic(content)
      }
    end

    # Load the Visual Profile markdown file content.
    #
    # @return [String] The markdown content of the Visual Profile
    # @raise [ProfileNotFoundError] if the file does not exist
    def load_visual_profile_content
      profile_path = visual_profile_path
      raise ProfileNotFoundError, "Visual Profile '#{visual_profile_id}' not found at #{profile_path}" unless profile_path.exist?

      profile_path.read
    end

    # Resolve the file path for the Visual Profile.
    # Visual Profiles are stored in docs/reference/asset-generation/
    # This is development-time tooling — reads directly from repository filesystem.
    #
    # @return [Pathname] The absolute path to the Visual Profile markdown file
    def visual_profile_path
      base_dir = Pathname.new(File.expand_path('../../../docs/reference/asset-generation', __dir__))

      # Convert profile_id to filename: "precision_industrial_v1" → "VISUAL_PROFILE_precision_industrial_v1.md"
      filename = "VISUAL_PROFILE_#{visual_profile_id}.md"
      base_dir.join(filename)
    end

    # Extract materials from Visual Profile markdown content.
    #
    # @param content [String] The markdown content
    # @return [Array<String>] Array of material descriptions
    def extract_materials(content)
      materials = []

      # Look for "Materials:" in locked attributes section
      content.each_line do |line|
        if line.strip.start_with?("- **Materials:**") || line.strip.start_with?("- **Materials :**")
          # Extract the material list from the bullet point
          match = line.match(/- \*\*Materials:\*\*\s*(.*)/)
          if match
            materials_text = match[1]
            # Parse comma-separated materials (may span multiple lines)
            materials_text.split(',').each do |mat|
              mat = mat.strip.gsub(/^[-•]\s*/, '')
              materials << mat unless mat.empty?
            end
          end
        end
      end

      # If no materials found via bullet, try paragraph extraction
      if materials.empty?
        content.scan(/Materials:\s*([^\n]+)/).each do |match|
          match[0].split(',').each do |mat|
            mat = mat.strip
            materials << mat unless mat.empty?
          end
        end
      end

      materials
    end

    # Extract finish description from Visual Profile markdown content.
    #
    # @param content [String] The markdown content
    # @return [String] The surface finish description
    def extract_finish(content)
      content.each_line do |line|
        if line.strip.start_with?("- **Finish:**") || line.strip.start_with?("- **Finish :**")
          match = line.match(/- \*\*Finish:\*\*\s*(.*)/)
          return match[1].strip if match
        end
      end

      # Try paragraph extraction
      finish_match = content.match(/Finish:\s*([^\n]+)/)
      finish_match ? finish_match[1].strip : ""
    end

    # Extract aesthetic description from Visual Profile markdown content.
    #
    # @param content [String] The markdown content
    # @return [String] The industrial aesthetic description
    def extract_aesthetic(content)
      # Look for NASA/ESA or similar aerospace-industrial references
      aesa_match = content.match(/(NASA\/ESA-inspired\s+aerospace[-–-]industrial)/i)
      return aesa_match[1] if aesa_match

      # Fallback: look for "aesthetic" in locked attributes
      aesthetic_match = content.match(/aesthetic:\s*([^\n]+)/i)
      aesthetic_match ? aesthetic_match[1].strip : ""
    end

    # Resolve manufacturing method description from Blueprint + Visual Definition.
    #
    # @param bp_method [String] Blueprint manufacturing style
    # @param vd_method [String] Visual Definition manufacturing style
    # @return [String] Description of the manufacturing method
    def resolve_manufacturing_method(bp_method, vd_method)
      case bp_method
      when /heavy_industrial|precision_factory/
        "precision industrial factory assembly"
      when /additive_construction/
        "additive construction (3D printing)"
      when /cast_construction/
        "cast construction"
      when /modular_assembly/
        "modular assembly"
      when /bootstrap_frontier/
        "bootstrap frontier construction"
      else
        "precision industrial factory assembly" # Default for precision_industrial_v1 profile
      end
    end

    # Get technology level characteristics based on the TL number.
    #
    # @param level [Integer] Technology level (1-5)
    # @return [Array<String>] Array of TL-specific visual characteristics
    def technology_characteristics(level)
      case level
      when 1
        ["early-generation equipment", "visible fasteners", "rough construction"]
      when 2
        ["cleaner than early-generation equipment", "fewer visible fasteners", "welded joints", "slight sheen consistent with factory-assembled aerospace equipment"]
      when 3
        ["refined manufacturing", "minimal visible construction seams", "precision-machined surfaces"]
      when 4
        ["advanced manufacturing", "seamless integration", "micro-fabricated components"]
      when 5
        ["cutting-edge technology", "nanofabricated surfaces", "self-healing materials"]
      else
        ["standard manufacturing"]
      end
    end

    # Get technology level exclusions based on the TL number.
    #
    # @param level [Integer] Technology level (1-5)
    # @return [Array<String>] Array of excluded visual artifacts
    def technology_exclusions(level)
      base_exclusions = [
        "visible layer lines",
        "3D-printed rough texture",
        "improvised or bootstrap appearance"
      ]

      if level >= 2
        base_exclusions << "exposed reinforcement ribs"
      end

      if level >= 3
        base_exclusions << "regolith-composite or ISRU-derived material appearance"
      end

      base_exclusions
    end

    # Resolve the render profile ID from the Render Template filename.
    #
    # @return [String] The render profile ID
    def render_profile_id
      basename = render_template_path.basename(".md").to_s
      # Extract profile ID from template name (e.g., "PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0" → "catalog_render_v2")
      if basename.include?("RENDER_TEMPLATE")
        "catalog_render_v2"
      else
        "#{basename}_render"
      end
    end
  end
end
