require 'rails_helper'

RSpec.describe Lookup::PlanetaryGeologicalFeatureLookupService do
  let(:star) { create(:star) }
  let(:sol) { create(:solar_system, current_star: star, name: 'Sol') }
  let(:earth) { create(:terrestrial_planet, :earth, solar_system: sol) }
  let(:mars) { create(:terrestrial_planet, :mars, solar_system: sol) }
  
  # Mock the JSON_DATA path for testing
  before do
    stub_const('GalaxyGame::Paths::JSON_DATA', 'spec/fixtures/data')
    # Clean up any existing test files
    cleanup_test_files
  end

  # Clean up test files after each test
  after do
    cleanup_test_files
  end

  describe "#initialize" do
    it "initializes with a celestial body" do
      service = described_class.new(earth)
      expect(service).to be_an_instance_of(described_class)
    end

    it "loads features during initialization" do
      # Create test fixture
      create_test_feature_file(earth, [
        { "name" => "Mount Everest", "type" => "mountain" }
      ])
      
      service = described_class.new(earth)
      expect(service.all_features).not_to be_empty
    end
  end

  describe "#all_features" do
    it "returns an empty array when no features exist" do
      service = described_class.new(mars)
      expect(service.all_features).to eq([])
    end

    it "returns all loaded features" do
      features_data = [
        { "name" => "Mount Everest", "type" => "mountain", "elevation" => 8848 },
        { "name" => "Mariana Trench", "type" => "trench", "depth" => -11034 }
      ]
      
      create_test_feature_file(earth, features_data)
      service = described_class.new(earth)
      
      expect(service.all_features.length).to eq(2)
      expect(service.all_features.first["name"]).to eq("Mount Everest")
      expect(service.all_features.last["name"]).to eq("Mariana Trench")
    end

    it "handles multiple JSON files" do
      create_test_feature_file(earth, [
        { "name" => "Feature 1", "type" => "mountain" }
      ], "mountains.json")
      
      create_test_feature_file(earth, [
        { "name" => "Feature 2", "type" => "ocean" }
      ], "oceans.json")
      
      service = described_class.new(earth)
      expect(service.all_features.length).to eq(2)
    end

    it "handles single feature JSON files" do
      create_test_feature_file(earth, 
        { "name" => "Single Feature", "type" => "crater" }
      )
      
      service = described_class.new(earth)
      expect(service.all_features.length).to eq(1)
      expect(service.all_features.first["name"]).to eq("Single Feature")
    end
  end

  describe "#find_by_name" do
    let(:features_data) do
      [
        { "name" => "Mount Everest", "type" => "mountain" },
        { "name" => "Pacific Ocean", "type" => "ocean" },
        { "name" => "Grand Canyon", "type" => "canyon" }
      ]
    end

    before do
      create_test_feature_file(earth, features_data)
    end

    it "finds a feature by exact name match" do
      service = described_class.new(earth)
      feature = service.find_by_name("Mount Everest")
      
      expect(feature).not_to be_nil
      expect(feature["name"]).to eq("Mount Everest")
      expect(feature["type"]).to eq("mountain")
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
      duplicate_features = [
        { "name" => "Duplicate", "type" => "mountain", "id" => 1 },
        { "name" => "Duplicate", "type" => "crater", "id" => 2 }
      ]
      
      create_test_feature_file(earth, duplicate_features)
      service = described_class.new(earth)
      feature = service.find_by_name("Duplicate")
      
      expect(feature["id"]).to eq(1)
    end
  end

  describe "#features_by_type" do
    let(:features_data) do
      [
        { "name" => "Mount Everest", "type" => "mountain" },
        { "name" => "K2", "type" => "mountain" },
        { "name" => "Pacific Ocean", "type" => "ocean" },
        { "name" => "Meteor Crater", "type" => "crater" }
      ]
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
      [
        { "name" => "Mount Everest", "type" => "mountain" },
        { "name" => "K2", "type" => "mountain" },
        { "name" => "Pacific Ocean", "type" => "ocean" },
        { "name" => "Unnamed Feature" } # No type
      ]
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
      expected_path = Rails.root.join('spec/fixtures/data/star_systems/sol/celestial_bodies/earth')
      
      # Use send to access private method for testing
      actual_path = service.send(:body_feature_path)
      expect(actual_path.to_s).to eq(expected_path.to_s)
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
      create_test_feature_file(earth, [{ "name" => "Test", "type" => "test" }])
      
      # Allow any debug messages, but ensure we get the specific one we care about
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

  def cleanup_test_files
    test_fixtures_path = Rails.root.join('spec/fixtures/data')
    FileUtils.rm_rf(test_fixtures_path) if File.exist?(test_fixtures_path)
  end

  def build_fixture_path(celestial_body)
    system_name = celestial_body&.solar_system&.name || 'sol'
    path_parts = [
      Rails.root,
      'spec/fixtures/data',
      'star_systems',
      system_name.downcase,
      'celestial_bodies'
    ]

    # Only handle planets for now - no parent_body logic
    path_parts << celestial_body.name.downcase
    File.join(*path_parts)
  end
end