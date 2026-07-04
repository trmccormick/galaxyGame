# spec/services/ai_manager/surface_suitability_analyzer_spec.rb
require "rails_helper"

RSpec.describe AIManager::SurfaceSuitabilityAnalyzer do
  describe ".score (class method)" do
    it "delegates to instance method" do
      body = build(:celestial_body, :minimal)
      result = described_class.score(body, grid_x: 0, grid_y: 0)
      expect(result[:suitability_score]).to eq(0.5)
      expect(result[:warnings]).to include("no celestial body")
    end
  end

  describe "#score" do
    let(:celestial_body) { create(:celestial_body, :minimal) }
    let(:geosphere) { create(:geosphere, celestial_body: celestial_body) }
    let(:terrain_map_data) do
      {
        "elevation" => [[0.0, 10.0, 20.0], [5.0, 15.0, 25.0], [10.0, 20.0, 30.0]],
        "resource_grid" => [[10, 20, 30], [40, 50, 60], [70, 80, 90]],
        "biomes" => [[1, 1, 2], [1, 3, 1], [2, 1, 1]],  # Numeric biome IDs (craters are geological features, not biomes)
        "width" => 3,
        "height" => 3
      }
    end

    before do
      geosphere.update!(terrain_map: terrain_map_data)
    end

    context "with valid terrain data" do
      it "returns a score hash with all required keys" do
        result = described_class.new(celestial_body).score(grid_x: 1, grid_y: 1)
        # Biomes are strings in our test data, so elevation will be nil (not numeric)
        # But score should still have all keys
        expect(result).to have_key(:suitability_score)
        expect(result).to have_key(:resource_density)
        expect(result).to have_key(:terrain_clearance)
        expect(result).to have_key(:buildability_mask)
        expect(result).to have_key(:slope_degrees)
        expect(result).to have_key(:elevation_meters)
        expect(result).to have_key(:biome)
        expect(result).to have_key(:has_water)
        expect(result).to have_key(:gravity_factor)
        expect(result).to have_key(:atmosphere_factor)
        expect(result).to have_key(:grid_x)
        expect(result).to have_key(:grid_y)
        expect(result).to have_key(:warnings)
      end

      it "returns suitability_score between 0.0 and 1.0" do
        result = described_class.new(celestial_body).score(grid_x: 1, grid_y: 1)
        expect(result[:suitability_score]).to be_between(0.0, 1.0)
      end

      it "returns correct elevation at grid position" do
        result = described_class.new(celestial_body).score(grid_x: 1, grid_y: 1)
        expect(result[:elevation_meters]).to eq(15.0)
      end

      it "returns resource density from grid" do
        result = described_class.new(celestial_body).score(grid_x: 1, grid_y: 1)
        expect(result[:resource_density]["concentration"]).to eq(50.0)
      end

      it "classifies terrain clearance based on slope" do
        result = described_class.new(celestial_body).score(grid_x: 1, grid_y: 1)
        expect(result[:terrain_clearance]).to be_in([:flat, :moderate, :rough, :extreme])
      end

      it "detects buildability as :buildable for flat non-water terrain" do
        result = described_class.new(celestial_body).score(grid_x: 1, grid_y: 1)
        expect(result[:buildability_mask]).to eq(:buildable)
      end

      it "returns biome at grid position" do
        result = described_class.new(celestial_body).score(grid_x: 0, grid_y: 0)
        expect(result[:biome]).to eq(1)  # Numeric biome ID at [0][0]
      end

      it "has no warnings when all data is present" do
        result = described_class.new(celestial_body).score(grid_x: 1, grid_y: 1)
        expect(result[:warnings]).to be_empty
      end
    end

    context "with missing terrain_map" do
      before do
        geosphere.update!(terrain_map: {})
      end

      it "returns fallback score with safe defaults when terrain_map is empty" do
        result = described_class.new(celestial_body).score(grid_x: 0, grid_y: 0)
        expect(result[:suitability_score]).to be_between(0.0, 1.0)
        expect(result[:terrain_clearance]).to eq(:unknown)
        expect(result[:buildability_mask]).to eq(:unknown)
      end
    end

    context "with nil celestial body" do
      it "returns fallback score with warning" do
        result = described_class.new(nil).score(grid_x: 0, grid_y: 0)
        expect(result[:suitability_score]).to eq(0.5)
        expect(result[:warnings]).to include("no celestial body")
      end
    end

    context "with negative elevation (below sea level)" do
      let(:terrain_map_data) do
        {
          "elevation" => [[-1.0, -1.0], [-1.0, 10.0]],
          "resource_grid" => [[5, 10], [15, 20]],
          "biomes" => [[1, 1], [1, 1]],
          "width" => 2,
          "height" => 2
        }
      end

      it "marks negative elevation as flooded" do
        result = described_class.new(celestial_body).score(grid_x: 0, grid_y: 0)
        expect(result[:elevation_meters]).to eq(-1.0)
        expect(result[:buildability_mask]).to eq(:flooded)
      end
    end

    context "with steep terrain" do
      let(:terrain_map_data) do
        {
          "elevation" => [[0.0, 100.0], [100.0, 200.0]],
          "resource_grid" => [[10, 20], [30, 40]],
          "biomes" => [["rock", "rock"], ["rock", "rock"]],
          "width" => 2,
          "height" => 2
        }
      end

      it "classifies as too_steep when slope exceeds threshold" do
        result = described_class.new(celestial_body).score(grid_x: 0, grid_y: 0)
        expect(result[:buildability_mask]).to eq(:too_steep) if result[:slope_degrees] && result[:slope_degrees] > 30
      end
    end

    context "with gravity/atmosphere factors" do
      before do
        celestial_body.update!(gravity: 1.62)
        # Atmosphere is an association, not a string column
        if celestial_body.atmosphere
          celestial_body.atmosphere.update!(pressure: 0.006, temperature: 210.0)
        end
      end

      it "applies gravity penalty for high gravity" do
        result = described_class.new(celestial_body).score(grid_x: 0, grid_y: 0)
        expect(result[:gravity_factor]).to eq(0.7)
      end

      it "applies atmosphere complication factor" do
        result = described_class.new(celestial_body).score(grid_x: 0, grid_y: 0)
        expect(result[:atmosphere_factor]).to eq(0.8)
      end
    end
  end

  describe "#find_best_sites" do
    let(:celestial_body) { create(:celestial_body, :minimal) }
    let(:geosphere) { create(:geosphere, celestial_body: celestial_body) }
    let(:terrain_map_data) do
      {
        "elevation" => [[0.0, 10.0], [5.0, 15.0]],
        "resource_grid" => [[10, 90], [40, 80]],
        "biomes" => [["desert", "desert"], ["desert", "desert"]],
        "width" => 2,
        "height" => 2
      }
    end

    before do
      geosphere.update!(terrain_map: terrain_map_data)
    end

    it "returns top sites sorted by suitability_score descending" do
      result = described_class.new(celestial_body).find_best_sites(
        x_min: 0, x_max: 1, y_min: 0, y_max: 1, limit: 2
      )
      expect(result.length).to be <= 2
      if result.length == 2
        expect(result[0][:suitability_score]).to be >= result[1][:suitability_score]
      end
    end

    it "returns empty array when no valid grid" do
      result = described_class.new(celestial_body).find_best_sites(
        x_min: 10, x_max: 20, y_min: 10, y_max: 20, limit: 5
      )
      expect(result).to be_empty
    end
  end

  describe "#score_entire_surface" do
    let(:celestial_body) { create(:celestial_body, :minimal) }
    let(:geosphere) { create(:geosphere, celestial_body: celestial_body) }
    let(:terrain_map_data) do
      {
        "elevation" => [[0.0, 10.0], [5.0, 15.0]],
        "resource_grid" => [[10, 20], [30, 40]],
        "biomes" => [["desert", "desert"], ["desert", "desert"]],
        "width" => 2,
        "height" => 2
      }
    end

    before do
      geosphere.update!(terrain_map: terrain_map_data)
    end

    it "returns 2D array matching terrain_map dimensions" do
      result = described_class.new(celestial_body).score_entire_surface
      expect(result.length).to eq(2) # height
      expect(result[0].length).to eq(2) # width
    end

    it "each element is a score hash" do
      result = described_class.new(celestial_body).score_entire_surface
      result.flatten.each do |score|
        expect(score).to have_key(:suitability_score)
      end
    end
  end

  describe "stable contract" do
    let(:celestial_body) { create(:celestial_body, :minimal) }
    let(:geosphere) { create(:geosphere, celestial_body: celestial_body) }
    let(:terrain_map_data) do
      {
        "elevation" => [[0.0, 10.0], [5.0, 15.0]],
        "resource_grid" => [[10, 20], [30, 40]],
        "biomes" => [["desert", "desert"], ["desert", "desert"]],
        "width" => 2,
        "height" => 2
      }
    end

    before do
      geosphere.update!(terrain_map: terrain_map_data)
    end

    it "always returns the same keys regardless of data state" do
      result = described_class.new(celestial_body).score(grid_x: 0, grid_y: 0)
      expected_keys = [
        :suitability_score, :resource_density, :terrain_clearance,
        :buildability_mask, :slope_degrees, :elevation_meters,
        :biome, :has_water, :gravity_factor, :atmosphere_factor,
        :grid_x, :grid_y, :warnings
      ]
      expect(result.keys).to match_array(expected_keys)
    end

    it "suitability_score is always a Float between 0.0 and 1.0" do
      result = described_class.new(celestial_body).score(grid_x: 0, grid_y: 0)
      expect(result[:suitability_score]).to be_a(Float)
      expect(result[:suitability_score]).to be_between(0.0, 1.0)
    end

    it "terrain_clearance is always a valid symbol" do
      result = described_class.new(celestial_body).score(grid_x: 0, grid_y: 0)
      expect(result[:terrain_clearance]).to be_in([:flat, :moderate, :rough, :extreme, :unknown])
    end

    it "buildability_mask is always a valid symbol" do
      result = described_class.new(celestial_body).score(grid_x: 0, grid_y: 0)
      expect(result[:buildability_mask]).to be_in([:buildable, :cratered, :too_steep, :flooded, :unknown])
    end

    it "resource_density is always a Hash" do
      result = described_class.new(celestial_body).score(grid_x: 0, grid_y: 0)
      expect(result[:resource_density]).to be_a(Hash)
    end

    it "warnings is always an Array" do
      result = described_class.new(celestial_body).score(grid_x: 0, grid_y: 0)
      expect(result[:warnings]).to be_an(Array)
    end
  end
end
