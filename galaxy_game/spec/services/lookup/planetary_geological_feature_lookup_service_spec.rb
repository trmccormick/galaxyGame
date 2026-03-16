require 'rails_helper'

RSpec.describe Lookup::PlanetaryGeologicalFeatureLookupService do
  # Use real Luna data from data/json-data
  let(:luna_data_path) { Rails.root.join('data', 'json-data', 'star_systems', 'sol', 'celestial_bodies', 'earth', 'luna', 'geological_features') }
  let(:sol) { double('SolarSystem', name: 'Sol') }
  let(:earth) { double('Planet', name: 'Earth', solar_system: sol, parent_celestial_body: nil) }
  let(:luna) { double('Moon', name: 'Luna', solar_system: sol, parent_celestial_body: earth) }

  before do
    stub_const('GalaxyGame::Paths::JSON_DATA', Rails.root.join('data', 'json-data'))
  end

  describe "#initialize and #all_features with real Luna data" do
    it "loads all Luna features from real data" do
      service = described_class.new(luna)
      features = service.all_features
      expect(features).not_to be_empty
      names = features.map { |f| f["name"] }
      expect(names).to include("Shackleton Crater")
      expect(names).to include("Marius Hills Skylight")
    end
  end

  describe "#find_by_name with real Luna data" do
    it "finds Shackleton Crater by name" do
      service = described_class.new(luna)
      feature = service.find_by_name("Shackleton Crater")
      expect(feature).not_to be_nil
      expect(feature["feature_type"]).to eq("crater")
    end

    it "finds Marius Hills Skylight by name" do
      service = described_class.new(luna)
      feature = service.find_by_name("Marius Hills Skylight")
      expect(feature).not_to be_nil
      expect(feature["feature_type"]).to eq("lava_tube")
    end
  end

  describe "#features_by_type with real Luna data" do
    it "returns all craters" do
      service = described_class.new(luna)
      craters = service.features_by_type("crater")
      expect(craters).not_to be_empty
      expect(craters.any? { |f| f["name"] == "Shackleton Crater" }).to be true
    end

    it "returns all lava tubes" do
      service = described_class.new(luna)
      tubes = service.features_by_type("lava_tube")
      expect(tubes).not_to be_empty
      expect(tubes.any? { |f| f["name"] == "Marius Hills Skylight" }).to be true
    end
  end

  describe "#feature_summary with real Luna data" do
    it "groups features by type" do
      service = described_class.new(luna)
      summary = service.feature_summary
      expect(summary.keys).to include("crater", "lava_tube")
      expect(summary["crater"].any? { |f| f["name"] == "Shackleton Crater" }).to be true
      expect(summary["lava_tube"].any? { |f| f["name"] == "Marius Hills Skylight" }).to be true
    end
  end
end

  describe "#all_features" do
    it "returns an empty array when no features exist" do
      service = described_class.new(mars)
      expect(service.all_features).to eq([])
    end

    it "returns all loaded features" do
      features_data = {
        "celestial_body" => "earth",
        "features" => [
          { "name" => "Mount Everest", "feature_type" => "mountain", "elevation" => 8848, "tier" => "strategic" },
          { "name" => "Mariana Trench", "feature_type" => "trench", "depth" => -11034, "tier" => "strategic" }
        ]
      }
      
      create_test_feature_file(earth, features_data)
      service = described_class.new(earth)
      
      expect(service.all_features.length).to eq(2)
      expect(service.all_features.first["name"]).to eq("Mount Everest")
      expect(service.all_features.last["name"]).to eq("Mariana Trench")
    end

    it "handles multiple JSON files" do
      create_test_feature_file(earth, {
        "features" => [
          { "name" => "Feature 1", "feature_type" => "mountain", "tier" => "strategic" }
        ]
      }, "mountains.json")
      
      create_test_feature_file(earth, {
        "features" => [
          { "name" => "Feature 2", "feature_type" => "ocean", "tier" => "strategic" }
        ]
      }, "oceans.json")
      
      service = described_class.new(earth)
      expect(service.all_features.length).to eq(2)
    end

    it "handles single feature JSON files" do
      create_test_feature_file(earth, {
        "features" => [
          { "name" => "Single Feature", "feature_type" => "crater", "tier" => "strategic" }
        ]
      })
      
      service = described_class.new(earth)
      expect(service.all_features.length).to eq(1)
      expect(service.all_features.first["name"]).to eq("Single Feature")
    end
  end

  describe "#find_by_name" do
    let(:features_data) do
      {
        "features" => [
          { "name" => "Mount Everest", "feature_type" => "mountain", "tier" => "strategic" },
          { "name" => "Pacific Ocean", "feature_type" => "ocean", "tier" => "strategic" },
          { "name" => "Grand Canyon", "feature_type" => "canyon", "tier" => "strategic" }
        ]
      }
    end

    before do
      create_test_feature_file(earth, features_data)
    end

    it "finds a feature by exact name match" do
      service = described_class.new(earth)
      feature = service.find_by_name("Mount Everest")
      
      expect(feature).not_to be_nil
      expect(feature["name"]).to eq("Mount Everest")
      expect(feature["feature_type"]).to eq("mountain")
    end

    it "finds a feature by case-insensitive name match" do
      service = described_class.new(earth)
      feature = service.find_by_name("MOUNT EVEREST")
      
      expect(feature).not_to be_nil
      expect(feature["name"]).to eq("Mount Everest")
    end

    it "finds a feature by lowercase name match" do
      service = described_class.new(earth)
      feature = service.find_by_name("pacific ocean")
      
      expect(feature).not_to be_nil
      expect(feature["name"]).to eq("Pacific Ocean")
    end

    it "returns nil when feature is not found" do
      service = described_class.new(earth)
      feature = service.find_by_name("Nonexistent Feature")
      
      expect(feature).to be_nil
    end

    it "handles symbol input" do
      service = described_class.new(earth)
      feature = service.find_by_name(:grand_canyon)
      
      expect(feature).to be_nil # Won't match because of underscore
      
      feature = service.find_by_name(:"Grand Canyon")
      expect(feature).not_to be_nil
    end

    it "returns the first match when multiple features have the same name" do
      duplicate_features = {
        "features" => [
          { "name" => "Duplicate", "feature_type" => "mountain", "id" => 1, "tier" => "strategic" },
          { "name" => "Duplicate", "feature_type" => "crater", "id" => 2, "tier" => "strategic" }
        ]
      }
      
      create_test_feature_file(earth, duplicate_features)
      service = described_class.new(earth)
      feature = service.find_by_name("Duplicate")
      
      expect(feature["id"]).to eq(1)
    end
  end

  describe "#features_by_type" do
    let(:features_data) do
      {
        "features" => [
          { "name" => "Mount Everest", "feature_type" => "mountain", "tier" => "strategic" },
          { "name" => "K2", "feature_type" => "mountain", "tier" => "strategic" },
          { "name" => "Pacific Ocean", "feature_type" => "ocean", "tier" => "strategic" },
          { "name" => "Meteor Crater", "feature_type" => "crater", "tier" => "strategic" }
        ]
      }
    end

    before do
      create_test_feature_file(earth, features_data)
    end

    it "returns features of a specific type" do
      service = described_class.new(earth)
      mountains = service.features_by_type("mountain")
      
      expect(mountains.length).to eq(2)
      expect(mountains.map { |f| f["name"] }).to contain_exactly("Mount Everest", "K2")
    end

    it "returns features by case-insensitive type match" do
      service = described_class.new(earth)
      mountains = service.features_by_type("MOUNTAIN")
      
      expect(mountains.length).to eq(2)
    end

    it "returns empty array when no features of that type exist" do
      service = described_class.new(earth)
      deserts = service.features_by_type("desert")
      
      expect(deserts).to eq([])
    end

    it "handles symbol input" do
      service = described_class.new(earth)
      oceans = service.features_by_type(:ocean)
      
      expect(oceans.length).to eq(1)
      expect(oceans.first["name"]).to eq("Pacific Ocean")
    end
  end

  describe "#feature_summary" do
    let(:features_data) do
      {
        "features" => [
          { "name" => "Mount Everest", "feature_type" => "mountain", "tier" => "strategic" },
          { "name" => "K2", "feature_type" => "mountain", "tier" => "strategic" },
          { "name" => "Pacific Ocean", "feature_type" => "ocean", "tier" => "strategic" },
          { "name" => "Unnamed Feature", "tier" => "strategic" } # No type
        ]
      }
    end

    before do
      create_test_feature_file(earth, features_data)
    end

    it "groups features by type" do
      service = described_class.new(earth)
      summary = service.feature_summary
      
      expect(summary).to have_key("mountain")
      expect(summary).to have_key("ocean")
      expect(summary).to have_key("unknown")
      
      expect(summary["mountain"].length).to eq(2)
      expect(summary["ocean"].length).to eq(1)
      expect(summary["unknown"].length).to eq(1)
    end

    it "handles features with nil type" do
      service = described_class.new(earth)
      summary = service.feature_summary
      
      expect(summary["unknown"].length).to eq(1)
      expect(summary["unknown"].first["name"]).to eq("Unnamed Feature")
    end

    it "returns empty hash when no features exist" do
      service = described_class.new(mars)
      summary = service.feature_summary
      
      expect(summary).to eq({})
    end
  end

  describe "path construction" do
    it "constructs correct path for planet" do
      service = described_class.new(earth)
      
      # Use send to access private method for testing
      actual_path = service.send(:body_feature_path)
      
      # Should end with geological_features
      expect(actual_path.to_s).to end_with('star_systems/sol/celestial_bodies/earth/geological_features')
    end

    it "handles missing solar system gracefully" do
      earth_no_system = create(:terrestrial_planet, name: 'Earth', solar_system: nil)
      service = described_class.new(earth_no_system)
      
      # Should default to 'sol'
      actual_path = service.send(:body_feature_path)
      expect(actual_path.to_s).to include('star_systems/sol')
    end
  end

  describe "error handling" do
    it "handles JSON parse errors gracefully" do
      # Create invalid JSON file
      create_invalid_json_file(earth)
      
      expect(Rails.logger).to receive(:warn).with(/Failed to parse/)
      
      service = described_class.new(earth)
      expect(service.all_features).to eq([])
    end

    it "handles missing directories gracefully" do
      # Don't create any files/directories
      service = described_class.new(mars)
      expect(service.all_features).to eq([])
    end

    it "logs debug information about found files" do
      create_test_feature_file(earth, {
        "features" => [{ "name" => "Test", "feature_type" => "test", "tier" => "strategic" }]
      })
      
      # Allow any debug messages
      allow(Rails.logger).to receive(:debug)
      expect(Rails.logger).to receive(:debug).with(/Found \d+ features for/)
      
      described_class.new(earth)
    end
  end

  # Helper methods for creating test fixtures
  private

  def create_test_feature_file(celestial_body, data, filename = "features.json")
    path = build_fixture_path(celestial_body)
    FileUtils.mkdir_p(path)
    
    File.write(File.join(path, filename), data.to_json)
  end

  def create_invalid_json_file(celestial_body)
    path = build_fixture_path(celestial_body)
    FileUtils.mkdir_p(path)
    
    File.write(File.join(path, "invalid.json"), "{ invalid json content")
  end

  def build_fixture_path(celestial_body)
    system_name = celestial_body&.solar_system&.name || 'sol'
    path_parts = [
      temp_test_dir,
      'star_systems',
      system_name.downcase,
      'celestial_bodies'
    ]

    path_parts << celestial_body.name.downcase
    path_parts << 'geological_features'  # Add new subdirectory
    
    File.join(*path_parts)
  end
end