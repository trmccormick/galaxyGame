# frozen_string_literal: true

require 'rspec'
require_relative '../profile_resolution_engine'

RSpec.describe AssetGeneration::ProfileResolutionEngine do
  let(:visual_profile_id) { "precision_industrial_v1" }
  let(:blueprint_data) do
    { technology_level: 2, manufacturing_style: "heavy_industrial" }
  end
  let(:visual_definition_data) do
    { technology_level: 2, manufacturing_style: "heavy_industrial" }
  end
  let(:render_template_path) do
    Pathname.new(File.expand_path(
      '../../../../docs/reference/asset-generation/PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md',
      __dir__
    ))
  end

  describe '.resolve' do
    subject(:result) do
      described_class.resolve(
        visual_profile_id: visual_profile_id,
        blueprint_data: blueprint_data,
        visual_definition_data: visual_definition_data,
        render_template_path: render_template_path
      )
    end

    it 'returns structured profile attributes' do
      expect(result).to be_a(Hash)
      expect(result.keys).to include(:global_visual_style, :manufacturing_style,
                                     :technology_level, :render_type, :warnings)
    end

    describe 'global_visual_style' do
      it 'resolves from Visual Profile locked attributes' do
        style = result[:global_visual_style]
        expect(style[:profile_id]).to eq("precision_industrial_v1")
        expect(style[:materials]).to be_an(Array)
        expect(style[:finish]).to be_a(String)
        expect(style[:aesthetic]).to be_a(String)
      end

      it 'extracts materials from locked attributes' do
        style = result[:global_visual_style]
        # precision_industrial_v1 includes aerospace steel, aluminum, etc.
        expect(style[:materials].any?).to be true
      end

      it 'extracts finish description' do
        style = result[:global_visual_style]
        expect(style[:finish]).to include("white") || include("gray") || include("black")
      end

      it 'extracts aesthetic description' do
        style = result[:global_visual_style]
        expect(style[:aesthetic]).to include("NASA") || include("ESA") || include("aerospace")
      end
    end

    describe 'manufacturing_style' do
      it 'resolves manufacturing method from blueprint data' do
        mfg = result[:manufacturing_style]
        expect(mfg[:method]).to include("industrial") || include("factory")
      end

      it 'includes excluded manufacturing styles' do
        mfg = result[:manufacturing_style]
        expect(mfg[:excluded]).to be_an(Array)
        expect(mfg[:excluded]).to include("frontier/bootstrap/improvised construction")
      end
    end

    describe 'technology_level' do
      it 'resolves technology level from blueprint data' do
        tl = result[:technology_level]
        expect(tl[:level]).to eq(2)
        expect(tl[:profile_id]).to eq("tl2_v1")
      end

      it 'includes TL-specific characteristics' do
        tl = result[:technology_level]
        expect(tl[:characteristics]).to be_an(Array)
        expect(tl[:characteristics]).to include("cleaner than early-generation equipment")
      end

      it 'includes TL-specific exclusions' do
        tl = result[:technology_level]
        expect(tl[:excluded]).to be_an(Array)
        expect(tl[:excluded]).to include("visible layer lines")
      end
    end

    describe 'render_type' do
      it 'resolves render type from Render Template' do
        rt = result[:render_type]
        expect(rt[:camera]).to include("top-down orthographic")
        expect(rt[:lighting]).to include("soft neutral studio")
        expect(rt[:background]).to include("transparent")
      end

      it 'sets framing to 75%' do
        rt = result[:render_type]
        expect(rt[:framing]).to eq("75% of canvas")
      end
    end

    describe 'cross-validation warnings' do
      context 'when Blueprint and Visual Definition tech levels match' do
        it 'returns no tech level warnings' do
          expect(result[:warnings]).not_to include(
            a_string_including("tech level mismatch")
          )
        end
      end

      context 'when Blueprint and Visual Definition tech levels differ' do
        let(:blueprint_data) do
          { technology_level: 1, manufacturing_style: "heavy_industrial" }
        end

        it 'returns a warning about the mismatch' do
          expect(result[:warnings]).to include(
            a_string_including("tech level mismatch")
          )
        end
      end

      context 'when Blueprint and Visual Definition manufacturing styles differ' do
        let(:visual_definition_data) do
          { technology_level: 2, manufacturing_style: "additive_construction" }
        end

        it 'returns a warning about the mismatch' do
          expect(result[:warnings]).to include(
            a_string_including("manufacturing style mismatch")
          )
        end
      end
    end
  end

  describe 'ProfileNotFoundError' do
    it 'raises when Visual Profile file does not exist' do
      expect {
        described_class.resolve(
          visual_profile_id: "nonexistent_profile_v1",
          blueprint_data: blueprint_data,
          visual_definition_data: visual_definition_data,
          render_template_path: render_template_path
        )
      }.to raise_error(AssetGeneration::ProfileResolutionEngine::ProfileNotFoundError)
    end
  end

  describe 'technology_characteristics' do
    it 'returns appropriate characteristics for TL1' do
      engine = described_class.new(
        visual_profile_id: visual_profile_id,
        blueprint_data: { technology_level: 1, manufacturing_style: "bootstrap_frontier" },
        visual_definition_data: { technology_level: 1, manufacturing_style: "bootstrap_frontier" },
        render_template_path: render_template_path
      )

      # Access private method via send for testing
      chars = engine.send(:technology_characteristics, 1)
      expect(chars).to include("early-generation equipment")
    end

    it 'returns appropriate characteristics for TL3' do
      engine = described_class.new(
        visual_profile_id: visual_profile_id,
        blueprint_data: { technology_level: 3, manufacturing_style: "precision_factory" },
        visual_definition_data: { technology_level: 3, manufacturing_style: "precision_factory" },
        render_template_path: render_template_path
      )

      chars = engine.send(:technology_characteristics, 3)
      expect(chars).to include("refined manufacturing")
    end
  end
end
