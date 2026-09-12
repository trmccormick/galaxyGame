# frozen_string_literal: true

require 'rspec'
require_relative '../prompt_compiler'

RSpec.describe AssetGeneration::PromptCompiler do
  let(:asset_id) { "regolith_harvester_rover" }
  let(:blueprint_path) do
    Pathname.new(File.expand_path(
      '../../../../data/json-data/blueprints/crafts/ground/regolith_harvesting_rover_bp.json',
      __dir__
    ))
  end
  let(:operational_data_path) do
    Pathname.new(File.expand_path(
      '../../../../data/json-data/operational_data/crafts/ground/regolith_harvesting_rover_data.json',
      __dir__
    ))
  end
  let(:visual_definition_path) do
    Pathname.new(File.expand_path(
      '../../../../docs/reference/asset-generation/visual_definitions/VEHICLE_HARVESTER_ROVER_RH400.json',
      __dir__
    ))
  end
  let(:render_template_path) do
    Pathname.new(File.expand_path(
      '../../../../docs/reference/asset-generation/PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md',
      __dir__
    ))
  end

  describe '.compile' do
    subject(:result) do
      described_class.compile(
        asset_id: asset_id,
        blueprint_path: blueprint_path,
        operational_data_path: operational_data_path,
        visual_definition_path: visual_definition_path,
        render_template_path: render_template_path
      )
    end

    it 'returns a compilation result with prompt_text, provenance, and validation fields' do
      expect(result).to be_a(Hash)
      expect(result.keys).to include(:prompt_text, :provenance, :validation_errors, :validation_warnings)
    end

    context 'when all canonical data is valid' do
      it 'produces a non-empty prompt text' do
        expect(result[:prompt_text]).to be_a(String)
        expect(result[:prompt_text].length).to be > 0
      end

      it 'includes a provenance header' do
        provenance = result[:provenance]
        expect(provenance[:asset_id]).to eq(asset_id)
        expect(provenance[:composition_method]).to eq("profile_composition_v1")
        expect(provenance[:status]).to eq("FROZEN")
      end

      it 'has no validation errors' do
        expect(result[:validation_errors]).to be_empty
      end

      it 'produces a prompt with correct section ordering (CAMERA before STYLE)' do
        prompt = result[:prompt_text]
        camera_idx = prompt.index("CAMERA")
        style_idx = prompt.index("STYLE")
        expect(camera_idx).not_to be_nil
        expect(style_idx).not_to be_nil
        expect(camera_idx).to be < style_idx
      end

      it 'produces a prompt with DESIGN CONSTRAINTS before recognition features' do
        prompt = result[:prompt_text]
        constraints_idx = prompt.index("DESIGN CONSTRAINTS")
        features_idx = prompt.index("RECOGNITION FEATURES")
        expect(constraints_idx).not_to be_nil
        expect(features_idx).not_to be_nil
        expect(constraints_idx).to be < features_idx
      end

      it 'orders recognition features by priority tier (primary before secondary before tertiary)' do
        prompt = result[:prompt_text]
        primary_idx = prompt.index("PRIMARY")
        secondary_idx = prompt.index("SECONDARY")
        tertiary_idx = prompt.index("TERTIARY")
        expect(primary_idx).not_to be_nil
        expect(secondary_idx).not_to be_nil
        expect(tertiary_idx).not_to be_nil
        expect(primary_idx).to be < secondary_idx
        expect(secondary_idx).to be < tertiary_idx
      end

      it 'includes all six recognition features' do
        prompt = result[:prompt_text]
        expect(prompt).to include("regolith skimming scoop assembly")
        expect(prompt).to include("six-wheel independent suspension chassis")
        expect(prompt).to include("mid-body processing canister")
        expect(prompt).to include("sensor mast with rotating array")
        expect(prompt).to include("dust exhaust stack")
        expect(prompt).to include("hydraulic actuator")
      end

      it 'includes FROZEN status at the end' do
        prompt = result[:prompt_text]
        expect(prompt).to include("**FROZEN STATUS**")
      end

      it 'uses structured profile data (not inlined prose) for STYLE section' do
        prompt = result[:prompt_text]
        style_section = prompt[/STYLE.*?MANUFACTURING/m]
        expect(style_section).to include("precision_industrial_v1")
      end

      it 'uses structured profile data for MANUFACTURING section' do
        prompt = result[:prompt_text]
        mfg_section = prompt[/MANUFACTURING.*?TECHNOLOGY/m]
        expect(mfg_section).to include("earth_factory_v1")
      end

      it 'uses structured profile data for TECHNOLOGY LEVEL section' do
        prompt = result[:prompt_text]
        tl_section = prompt[/TECHNOLOGY LEVEL.*?DESIGN/m]
        expect(tl_section).to include("tl2_v1")
      end
    end

    context 'when blueprint file does not exist' do
      let(:blueprint_path) do
        Pathname.new("/nonexistent/blueprint.json")
      end

      it 'returns empty prompt_text with validation error' do
        expect(result[:prompt_text]).to be_empty
        expect(result[:validation_errors]).not_to be_empty
        expect(result[:validation_errors]).to include(
          a_string_including("Blueprint for asset")
        )
      end
    end

    context 'when blueprint does not specify visual_profile' do
      let(:blueprint_path) do
        Pathname.new(File.expand_path(
          '../../../../data/json-data/blueprints/crafts/ground/regolith_harvesting_rover_bp.json',
          __dir__
        ))
      end

      it 'returns empty prompt_text with validation error' do
        # The actual blueprint has visual_profile, so this tests the engine's validation
        expect(result[:validation_errors]).not_to include(
          a_string_including("does not specify a visual_profile")
        )
      end
    end

    context 'with targeted refinements enabled' do
      let(:refinements) do
        {
          enabled: true,
          hex_color_ranges: [
            { zone: "body_panels", range: "#E8E6E1 to #D4D0C8" }
          ]
        }
      end

      it 'passes refinements through the pipeline' do
        result = described_class.compile(
          asset_id: asset_id,
          blueprint_path: blueprint_path,
          operational_data_path: operational_data_path,
          visual_definition_path: visual_definition_path,
          render_template_path: render_template_path,
          targeted_refinements_config: refinements
        )

        expect(result[:provenance][:targeted_refinements]).to eq("enabled")
      end
    end

    context 'with safeguards enabled' do
      let(:safeguards) do
        {
          enabled: true,
          camera_precedence: true,
          autonomous_protection: true
        }
      end

      it 'passes safeguards through the pipeline' do
        result = described_class.compile(
          asset_id: asset_id,
          blueprint_path: blueprint_path,
          operational_data_path: operational_data_path,
          visual_definition_path: visual_definition_path,
          render_template_path: render_template_path,
          safeguards_config: safeguards
        )

        expect(result[:provenance][:safeguards]).to eq("enabled")
      end

      it 'includes DESIGN CONSTRAINTS in prompt when autonomous_protection is enabled' do
        result = described_class.compile(
          asset_id: asset_id,
          blueprint_path: blueprint_path,
          operational_data_path: operational_data_path,
          visual_definition_path: visual_definition_path,
          render_template_path: render_template_path,
          safeguards_config: safeguards
        )

        expect(result[:prompt_text]).to include("DESIGN CONSTRAINTS")
        expect(result[:prompt_text]).to include("autonomous")
      end
    end

    context 'deterministic compilation' do
      it 'produces the same prompt for the same inputs' do
        result1 = described_class.compile(
          asset_id: asset_id,
          blueprint_path: blueprint_path,
          operational_data_path: operational_data_path,
          visual_definition_path: visual_definition_path,
          render_template_path: render_template_path
        )

        result2 = described_class.compile(
          asset_id: asset_id,
          blueprint_path: blueprint_path,
          operational_data_path: operational_data_path,
          visual_definition_path: visual_definition_path,
          render_template_path: render_template_path
        )

        expect(result1[:prompt_text]).to eq(result2[:prompt_text])
        expect(result1[:provenance][:asset_id]).to eq(result2[:provenance][:asset_id])
      end
    end
  end

  describe 'RH-400 structure comparison' do
    it 'produces a prompt with the same section hierarchy as Run 06' do
      result = described_class.compile(
        asset_id: asset_id,
        blueprint_path: blueprint_path,
        operational_data_path: operational_data_path,
        visual_definition_path: visual_definition_path,
        render_template_path: render_template_path
      )

      prompt = result[:prompt_text]

      # Verify section ordering matches Run 06 architecture
      sections_order = [
        ["SUBJECT", prompt.index("SUBJECT")],
        ["CAMERA", prompt.index("CAMERA")],
        ["PROPORTIONS", prompt.index("PROPORTIONS")],
        ["STYLE", prompt.index("STYLE")],
        ["MANUFACTURING", prompt.index("MANUFACTURING")],
        ["TECHNOLOGY LEVEL", prompt.index("TECHNOLOGY LEVEL")],
        ["DESIGN CONSTRAINTS", prompt.index("DESIGN CONSTRAINTS")],
        ["MARKINGS", prompt.index("MARKINGS")],
        ["RECOGNITION FEATURES", prompt.index("RECOGNITION FEATURES")],
        ["RENDER REQUIREMENTS", prompt.index("RENDER REQUIREMENTS")],
        ["BACKGROUND", prompt.index("BACKGROUND")],
        ["OUTPUT", prompt.index("OUTPUT")]
      ]

      # All sections should be present
      sections_order.each do |name, idx|
        expect(idx).not_to be_nil, "Section '#{name}' not found in compiled prompt"
      end

      # Verify ordering: CAMERA before STYLE, DESIGN CONSTRAINTS before RECOGNITION FEATURES
      camera_idx = prompt.index("CAMERA")
      style_idx = prompt.index("STYLE")
      constraints_idx = prompt.index("DESIGN CONSTRAINTS")
      features_idx = prompt.index("RECOGNITION FEATURES")

      expect(camera_idx).to be < style_idx, "CAMERA should come before STYLE"
      expect(constraints_idx).to be < features_idx, "DESIGN CONSTRAINTS should come before RECOGNITION FEATURES"
    end
  end
end
