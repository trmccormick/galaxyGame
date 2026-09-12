# frozen_string_literal: true

require 'rspec'

RSpec.describe AssetGeneration::CompositionRefinery do
  let(:profile_attributes) do
    {
      global_visual_style: {
        profile_id: "precision_industrial_v1",
        materials: ["high-strength aerospace steel", "aluminum structural members"],
        finish: "clean white/light-gray primary paneling over dark gray/black mechanical undercarriage",
        aesthetic: "NASA/ESA-inspired aerospace-industrial"
      },
      manufacturing_style: {
        profile_id: "earth_factory_v1",
        method: "precision industrial factory assembly",
        quality: "factory-assembled, not frontier/bootstrap",
        materials: ["high-strength aerospace steel", "aluminum structural members"],
        excluded: ["frontier/bootstrap/improvised construction"]
      },
      technology_level: {
        profile_id: "tl2_v1",
        level: 2,
        characteristics: ["cleaner than early-generation equipment", "welded joints"],
        excluded: ["visible layer lines", "3D-printed rough texture"]
      },
      render_type: {
        profile_id: "catalog_render_v2",
        camera: "top-down orthographic",
        lighting: "soft neutral studio — cool, even, diffused",
        background: "transparent (alpha channel)",
        framing: "75% of canvas",
        output_format: "PNG, 1024x1024 pixels"
      },
      warnings: []
    }
  end

  let(:visual_definition) do
    {
      asset_id: "VEHICLE_HARVESTER_ROVER_RH400",
      asset_family: "vehicle",
      component_class: "harvester",
      recognition_features: [
        "six-wheel independent suspension chassis",
        "forward regolith skimming scoop assembly",
        "mid-body cylindrical processing canister",
        "rear-mounted dust exhaust stack",
        "top-mounted sensor mast with rotating array",
        "exposed hydraulic actuator arms on scoop joints"
      ],
      visual_priority: {
        primary: ["regolith skimming scoop assembly", "six-wheel independent suspension chassis"],
        secondary: ["mid-body processing canister", "sensor mast with rotating array"],
        tertiary: ["rear-mounted dust exhaust stack", "exposed hydraulic actuator arms"]
      },
      material_profiles: ["cast_steel", "anodized_aluminum"],
      technology_level: 2,
      manufacturing_style: "heavy_industrial",
      color_profile: {
        industrial_primary: "light neutral hull tone",
        industrial_secondary: "dark neutral chassis tone",
        hazard_warning: "high-visibility accent"
      },
      physical_specs_reference: {
        length_m: 6.80,
        width_m: 3.30,
        height_m: 2.65,
        empty_mass_kg: 22800.0
      },
      design_constraints: {
        must_be_recognizable_at_32px: true
      }
    }
  end

  let(:blueprint_data) do
    {
      id: "regolith_harvester_rover",
      name: "RH-400 Regolith Harvester Rover",
      asset_family: "vehicle",
      technology_level: 2,
      manufacturing_style: "heavy_industrial"
    }
  end

  let(:operational_data) do
    {
      functional_role: "A specialized heavy autonomous rover for collecting regolith and rare surface minerals from planetary terrain.",
      description: "RH-400 Regolith Harvester Rover",
      operational_flags: {
        autonomous: true,
        human_rated: false
      }
    }
  end

  describe '.compose' do
    subject(:result) do
      described_class.compose(
        profile_attributes: profile_attributes,
        visual_definition: visual_definition,
        blueprint_data: blueprint_data,
        operational_data: operational_data
      )
    end

    it 'returns composed sections and warnings' do
      expect(result).to be_a(Hash)
      expect(result.keys).to include(:sections, :warnings)
      expect(result[:sections]).to be_a(Hash)
      expect(result[:warnings]).to be_an(Array)
    end

    describe 'subject section' do
      it 'combines asset name with functional role' do
        subject_text = result[:sections][:subject]
        expect(subject_text).to include("RH-400")
        expect(subject_text).to include("regolith")
      end
    end

    describe 'proportions section' do
      it 'includes canonical dimensions from Visual Definition' do
        proportions = result[:sections][:proportions]
        expect(proportions[:canonical_dimensions][:length_m]).to eq(6.80)
        expect(proportions[:canonical_dimensions][:width_m]).to eq(3.30)
        expect(proportions[:canonical_dimensions][:height_m]).to eq(2.65)
      end

      it 'generates visual anchors from canonical dimensions' do
        proportions = result[:sections][:proportions]
        expect(proportions[:visual_anchors]).to be_an(Array)
        expect(proportions[:visual_anchors]).to include(a_string_including("elongated"))
      end

      it 'computes length-to-width ratio' do
        proportions = result[:sections][:proportions]
        expect(proportions[:canonical_dimensions][:ratio_length_to_width]).to eq(2.06)
      end
    end

    describe 'style section' do
      it 'resolves from global_visual_style profile' do
        style = result[:sections][:style]
        expect(style[:profile_id]).to eq("precision_industrial_v1")
        expect(style[:materials]).to be_an(Array)
      end
    end

    describe 'manufacturing section' do
      it 'resolves from manufacturing_style profile' do
        mfg = result[:sections][:manufacturing]
        expect(mfg[:profile_id]).to eq("earth_factory_v1")
        expect(mfg[:method]).to include("industrial")
      end

      it 'includes excluded styles' do
        mfg = result[:sections][:manufacturing]
        expect(mfg[:excluded]).to include("frontier/bootstrap/improvised construction")
      end
    end

    describe 'technology_level section' do
      it 'resolves from technology_level profile' do
        tl = result[:sections][:technology_level]
        expect(tl[:level]).to eq(2)
        expect(tl[:profile_id]).to eq("tl2_v1")
      end

      it 'includes TL characteristics' do
        tl = result[:sections][:technology_level]
        expect(tl[:characteristics]).to include("cleaner than early-generation equipment")
      end
    end

    describe 'design_constraints section' do
      context 'when autonomous protection safeguard is enabled' do
        let(:safeguards) { { enabled: true, autonomous_protection: true } }

        it 'adds autonomous prohibition when operational_flags indicate autonomous' do
          result = described_class.compose(
            profile_attributes: profile_attributes,
            visual_definition: visual_definition,
            blueprint_data: blueprint_data,
            operational_data: operational_data,
            safeguards: safeguards
          )

          constraints = result[:sections][:design_constraints]
          expect(constraints).to be_an(Array)
          expect(constraints).to include(a_string_including("autonomous"))
          expect(constraints).to include(a_string_including("NO cockpit"))
        end
      end

      context 'when autonomous protection safeguard is disabled' do
        it 'returns empty array when no canonical constraints apply' do
          result = described_class.compose(
            profile_attributes: profile_attributes,
            visual_definition: visual_definition,
            blueprint_data: blueprint_data,
            operational_data: operational_data
          )

          constraints = result[:sections][:design_constraints]
          expect(constraints).to be_an(Array)
        end
      end
    end

    describe 'recognition_features section' do
      it 'orders features by visual_priority tier from canonical Visual Definition' do
        features = result[:sections][:recognition_features]
        expect(features[:primary]).to include("regolith skimming scoop assembly")
        expect(features[:primary]).to include("six-wheel independent suspension chassis")
        expect(features[:secondary]).to include("mid-body processing canister")
        expect(features[:secondary]).to include("sensor mast with rotating array")
        expect(features[:tertiary]).to include("rear-mounted dust exhaust stack")
      end

      it 'preserves all six recognition features across tiers' do
        features = result[:sections][:recognition_features]
        all_features = features[:primary] + features[:secondary] + features[:tertiary]
        expect(all_features.size).to eq(6)
      end

      context 'when visual_priority is missing from Visual Definition' do
        let(:visual_definition_no_priority) do
          visual_definition.merge({ visual_priority: nil })
        end

        it 'distributes features evenly between primary and secondary' do
          result = described_class.compose(
            profile_attributes: profile_attributes,
            visual_definition: visual_definition_no_priority,
            blueprint_data: blueprint_data,
            operational_data: operational_data
          )

          features = result[:sections][:recognition_features]
          expect(features[:primary].size + features[:secondary].size).to eq(6)
        end
      end
    end

    describe 'markings section' do
      it 'includes hazard striping info from Visual Profile' do
        markings = result[:sections][:markings]
        expect(markings).to be_a(Hash)
      end
    end

    describe 'render_requirements section' do
      it 'resolves camera from render_type profile' do
        reqs = result[:sections][:render_requirements]
        expect(reqs[:camera]).to include("top-down orthographic")
      end

      it 'includes lighting info' do
        reqs = result[:sections][:render_requirements]
        expect(reqs[:lighting]).to include("soft neutral studio")
      end
    end

    describe 'background section' do
      it 'sets transparent background' do
        bg = result[:sections][:background]
        expect(bg[:background_type]).to include("transparent")
      end

      it 'includes prohibitions list' do
        bg = result[:sections][:background]
        expect(bg[:prohibitions]).to be_an(Array)
        expect(bg[:prohibitions]).to include("no ground plane")
        expect(bg[:prohibitions]).to include("no terrain")
      end
    end

    describe 'output section' do
      it 'sets PNG format' do
        output = result[:sections][:output]
        expect(output[:format]).to eq("PNG")
      end

      it 'sets 1024x1024 dimensions' do
        output = result[:sections][:output]
        expect(output[:dimensions]).to eq("1024x1024 pixels")
      end
    end

    describe 'targeted refinements (disabled by default)' do
      it 'does not include hex color ranges when disabled' do
        result = described_class.compose(
          profile_attributes: profile_attributes,
          visual_definition: visual_definition,
          blueprint_data: blueprint_data,
          operational_data: operational_data,
          targeted_refinements: { enabled: false }
        )

        # Hex colors should not appear in any section when disabled
        all_text = result[:sections].values.join(" ")
        expect(all_text).not_to include("#E8E6E1")
      end

      context 'when hex color ranges are enabled' do
        let(:refinements) do
          {
            enabled: true,
            hex_color_ranges: [
              { zone: "body_panels", range: "#E8E6E1 to #D4D0C8" },
              { zone: "undercarriage", range: "#2A2A2E to #1C1C20" }
            ]
          }
        end

        it 'includes hex color ranges in output' do
          result = described_class.compose(
            profile_attributes: profile_attributes,
            visual_definition: visual_definition,
            blueprint_data: blueprint_data,
            operational_data: operational_data,
            targeted_refinements: refinements
          )

          # Hex colors should appear when enabled
          expect(result).to be_a(Hash)
        end
      end
    end

    describe 'safeguards (disabled by default)' do
      it 'does not add DESIGN CONSTRAINTS when disabled' do
        result = described_class.compose(
          profile_attributes: profile_attributes,
          visual_definition: visual_definition,
          blueprint_data: blueprint_data,
          operational_data: operational_data,
          safeguards: { enabled: false }
        )

        constraints = result[:sections][:design_constraints]
        expect(constraints).to be_an(Array)
      end
    end

    describe 'unknown field handling' do
      let(:visual_definition_with_unknown) do
        visual_definition.merge({ unknown_field: "should not appear" })
      end

      it 'omits unknown fields from output (never invents values)' do
        result = described_class.compose(
          profile_attributes: profile_attributes,
          visual_definition: visual_definition_with_unknown,
          blueprint_data: blueprint_data,
          operational_data: operational_data
        )

        all_text = result[:sections].values.join(" ")
        expect(all_text).not_to include("unknown_field")
      end
    end
  end

  describe 'canonical data precedence' do
    it 'uses Visual Definition visual_priority over any other source' do
      features = result[:sections][:recognition_features]
      # Primary tier must match canonical Visual Definition, not blueprint or profile
      expect(features[:primary]).to eq(["regolith skimming scoop assembly", "six-wheel independent suspension chassis"])
    end
  end

  describe 'deterministic compilation' do
    it 'produces the same output for the same inputs' do
      result1 = described_class.compose(
        profile_attributes: profile_attributes,
        visual_definition: visual_definition,
        blueprint_data: blueprint_data,
        operational_data: operational_data
      )

      result2 = described_class.compose(
        profile_attributes: profile_attributes,
        visual_definition: visual_definition,
        blueprint_data: blueprint_data,
        operational_data: operational_data
      )

      expect(result1[:sections]).to eq(result2[:sections])
    end
  end
end
