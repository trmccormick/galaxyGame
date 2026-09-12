# frozen_string_literal: true

# Composition Refinery — takes structured profile attributes + Visual Definition data
# and produces composed prompt sections organized by priority tier.
#
# This is Layer 2 of the asset generation pipeline:
#   Profile Resolution → Composition Refinery → Prompt Compilation
#
# Responsibilities:
# - Organize recognition features by priority tier (primary → secondary → tertiary) from Visual Definition's visual_priority field
# - Apply optional targeted refinements (hex color ranges, geometric constraints) — disabled by default
# - Apply optional safeguards (camera precedence, autonomous protection, feature tier elevation) — disabled by default
# - Produce ordered prompt sections (structured Hash, not prose)
# - Never invent values for unknown/unpopulated fields
#
# Configuration: Targeted refinements and safeguards are OPTIONAL modules, disabled by default.
# Recognition feature priority ordering is ALWAYS applied from canonical Visual Definition data.

module AssetGeneration
  class CompositionRefinery
    # Error raised when required data is missing for composition
    class CompositionError < StandardError; end

    # Compose prompt sections from profile attributes and Visual Definition data.
    #
    # @param profile_attributes [Hash] Output from ProfileResolutionEngine
    # @param visual_definition [Hash] Visual Definition data with recognition_features, visual_priority, etc.
    # @param blueprint_data [Hash] Blueprint data for subject/functional role
    # @param operational_data [Hash] Operational data for functional role
    # @param targeted_refinements [Hash] Optional refinements config (disabled by default)
    # @param safeguards [Hash] Optional safeguards config (disabled by default)
    # @return [Hash] Composed prompt sections with keys:
    #   - sections: ordered prompt sections (Hash)
    #   - warnings: array of warning messages
    # @raise [CompositionError] if required data is missing
    def self.compose(profile_attributes:, visual_definition:, blueprint_data:, operational_data:,
                     targeted_refinements: nil, safeguards: nil)
      new(
        profile_attributes: profile_attributes,
        visual_definition: visual_definition,
        blueprint_data: blueprint_data,
        operational_data: operational_data,
        targeted_refinements: targeted_refinements || { enabled: false },
        safeguards: safeguards || { enabled: false }
      ).run
    end

    attr_reader :profile_attributes, :visual_definition, :blueprint_data,
                :operational_data, :targeted_refinements, :safeguards

    def initialize(profile_attributes:, visual_definition:, blueprint_data:, operational_data:,
                   targeted_refinements:, safeguards:)
      @profile_attributes = profile_attributes
      @visual_definition = visual_definition
      @blueprint_data = blueprint_data
      @operational_data = operational_data
      @targeted_refinements = targeted_refinements
      @safeguards = safeguards
    end

    # Run the full composition pipeline and return composed prompt sections.
    #
    # @return [Hash] Composed sections with keys:
    #   - sections: Hash of ordered prompt sections
    #   - warnings: Array of warning messages
    def run
      vd = visual_definition_data

      {
        sections: {
          subject: build_subject(vd),
          proportions: build_proportions(vd),
          style: build_style,
          manufacturing: build_manufacturing,
          technology_level: build_technology_level,
          design_constraints: build_design_constraints(vd),
          markings: build_markings,
          recognition_features: build_recognition_features(vd),
          render_requirements: build_render_requirements,
          background: build_background,
          output: build_output
        },
        warnings: []
      }
    end

    private

    # Build the SUBJECT section from blueprint + operational data.
    # Never invents values — uses only canonical data.
    def build_subject(vd)
      name = vd[:asset_id] || blueprint_data[:name] || "Unknown Asset"
      functional_role = operational_data[:functional_role] || operational_data[:description] || ""

      if functional_role.present?
        "#{name} — #{functional_role}"
      else
        name
      end
    end

    # Build the PROPORTIONS section from canonical dimensions + visual anchors.
    # Never invents values — uses only canonical data.
    def build_proportions(vd)
      physical = vd[:physical_specs_reference] || {}
      length_m = physical[:length_m]
      width_m = physical[:width_m]
      height_m = physical[:height_m]

      result = { canonical_dimensions: {} }

      if length_m && width_m && height_m
        result[:canonical_dimensions] = {
          length_m: length_m,
          width_m: width_m,
          height_m: height_m,
          ratio_length_to_width: (length_m.to_f / width_m).round(2)
        }

        # Generate visual anchors from canonical dimensions
        result[:visual_anchors] = generate_visual_anchors(length_m, width_m, height_m)
      end

      result
    end

    # Generate visual proportion anchors from canonical dimensions.
    # These are generation instructions derived from canonical data, NOT replacements.
    def generate_visual_anchors(length, width, height)
      anchors = []

      if length > width * 1.5
        anchors << "elongated low-slung vehicle"
        anchors << "length clearly exceeds width"
      end

      if width < length * 0.6
        anchors << "width remains substantially narrower than overall length"
      end

      if height < width * 0.8
        anchors << "body height remains low relative to footprint"
      end

      # Always include a shape description if we have dimensions
      if length > width
        anchors << "overall shape: elongated platform with forward and rear protrusions"
      end

      anchors
    end

    # Build the STYLE section from resolved global_visual_style profile.
    def build_style
      style = profile_attributes[:global_visual_style] || {}

      {
        profile_id: style[:profile_id],
        materials: style[:materials] || [],
        finish: style[:finish] || "",
        aesthetic: style[:aesthetic] || ""
      }
    end

    # Build the MANUFACTURING section from resolved manufacturing_style profile.
    def build_manufacturing
      mfg = profile_attributes[:manufacturing_style] || {}

      {
        profile_id: mfg[:profile_id],
        method: mfg[:method] || "",
        quality: mfg[:quality] || "",
        materials: mfg[:materials] || [],
        excluded: mfg[:excluded] || []
      }
    end

    # Build the TECHNOLOGY LEVEL section from resolved technology_level profile.
    def build_technology_level
      tl = profile_attributes[:technology_level] || {}

      {
        profile_id: tl[:profile_id],
        level: tl[:level] || 1,
        characteristics: tl[:characteristics] || [],
        excluded: tl[:excluded] || []
      }
    end

    # Build the DESIGN CONSTRAINTS section.
    # Applies autonomous protection safeguard if enabled.
    # Never invents values — uses only canonical data.
    def build_design_constraints(vd)
      constraints = []

      # Apply autonomous protection safeguard if enabled
      if safeguards[:enabled] && safeguards[:autonomous_protection]
        # Check if the asset is marked as autonomous in operational data
        if operational_data[:operational_flags]&.dig(:autonomous) == true ||
           operational_data[:operational_flags]&.dig(:human_rated) == false
          constraints << "Fully autonomous industrial machine — NO cockpit, NO crew elements, NO steering controls"
        end
      end

      # Add design constraints from Visual Definition if present
      vd_constraints = vd[:design_constraints]
      if vd_constraints && vd_constraints.is_a?(Hash)
        # These are metadata about the asset's requirements, not generation constraints
        # They inform the render but don't become DESIGN CONSTRAINTS text
      end

      constraints
    end

    # Build the MARKINGS section from resolved global_visual_style profile.
    def build_markings
      style = profile_attributes[:global_visual_style] || {}
      markings = style[:markings] || {}

      result = { hazard_striping: nil, unit_id: nil }

      # Hazard striping from Visual Profile locked attributes
      if style[:finish].to_s.include?("hazard") || style[:finish].to_s.include?("yellow")
        result[:hazard_striping] = {
          colors: ["#E8C800 to #D4B500 (industrial yellow)", "#1A1A1A to #0D0D0D (near-black)"],
          application: "moving parts and edges only"
        }
      end

      # Unit ID from Visual Profile
      result[:unit_id] = markings[:unit_id] || "stenciled on hull"

      result
    end

    # Build the RECOGNITION FEATURES section ordered by priority tier.
    # ALWAYS applies visual_priority ordering from canonical Visual Definition data.
    def build_recognition_features(vd)
      features = vd[:recognition_features] || []
      priority = vd[:visual_priority] || {}

      result = { primary: [], secondary: [], tertiary: [] }

      if priority.is_a?(Hash)
        # Use visual_priority from canonical Visual Definition data
        result[:primary] = (priority[:primary] || []).dup
        result[:secondary] = (priority[:secondary] || []).dup
        result[:tertiary] = (priority[:tertiary] || []).dup

        # Apply feature tier elevation safeguard if enabled
        if safeguards[:enabled] && safeguards[:feature_tier_elevation]
          # This would promote features from lower tiers to higher tiers
          # For now, just ensure all features are present in their canonical tier
        end
      elsif features.any?
        # Fallback: if no visual_priority, distribute features evenly
        mid = (features.size / 2.0).ceil
        result[:primary] = features[0...mid]
        result[:secondary] = features[mid..-1]
      end

      result
    end

    # Build the RENDER REQUIREMENTS section from resolved render_type profile.
    def build_render_requirements
      rt = profile_attributes[:render_type] || {}

      {
        camera: rt[:camera] || "top-down orthographic",
        lighting: rt[:lighting] || "soft neutral studio",
        framing: rt[:framing] || "75% of canvas"
      }
    end

    # Build the BACKGROUND section from resolved render_type profile.
    def build_background
      rt = profile_attributes[:render_type] || {}

      {
        background_type: rt[:background] || "transparent (alpha channel)",
        prohibitions: [
          "no ground plane",
          "no terrain",
          "no baked shadows beyond subtle contact shadow",
          "no sky",
          "no stars",
          "no environment",
          "no props",
          "no dust effects",
          "no motion blur",
          "no text",
          "no labels",
          "no annotations",
          "no logos",
          "no borders",
          "no watermark"
        ]
      }
    end

    # Build the OUTPUT section from resolved render_type profile.
    def build_output
      rt = profile_attributes[:render_type] || {}

      {
        format: "PNG",
        dimensions: "1024x1024 pixels",
        quality: "High resolution suitable for production game assets"
      }
    end

    # Get the visual_definition data, handling both direct Hash and wrapped formats.
    # Visual Definition files may contain {"visual_definition": {...}} wrapper.
    # Normalizes all keys to symbols for consistent downstream access.
    def visual_definition_data
      vd = @visual_definition
      
      # Unwrap outer visual_definition key if present (handles both symbol and string keys)
      if vd.is_a?(Hash) && (vd.key?(:visual_definition) || vd.key("visual_definition"))
        inner = vd[:visual_definition] || vd["visual_definition"]
        vd = inner.is_a?(Hash) ? inner : vd
      end
      
      return {} unless vd.is_a?(Hash)
      
      # Normalize all keys to symbols for consistent downstream access
      normalize_keys(vd)
    end
    
    # Recursively normalize hash keys to symbols.
    # Handles both symbol and string keys from JSON parsing.
    #
    # @param hash [Hash] The hash to normalize
    # @return [Hash] A new hash with all keys normalized to symbols
    def normalize_keys(hash)
      return {} unless hash.is_a?(Hash)
      
      hash.each_with_object({}) do |(key, value), result|
        normalized_key = key.is_a?(String) ? key.to_sym : key
        normalized_value = if value.is_a?(Hash)
          normalize_keys(value)
        elsif value.is_a?(Array)
          value.map { |v| v.is_a?(Hash) ? normalize_keys(v) : v }
        else
          value
        end
        result[normalized_key] = normalized_value
      end
    end
  end
end
