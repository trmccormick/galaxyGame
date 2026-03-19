require 'rails_helper'

RSpec.describe Lookup::PlanetaryGeologicalFeatureLookupService do
  # Use real data and real path logic, no stubbing

  # Doubles must respond to both :solar_system and :star_system, and :parent_celestial_body and :parent_body
  let(:sol) { double('SolarSystem', name: 'Sol') }
  let(:earth) do
    double('Planet',
      name: 'Earth',
      star_system: sol,
      solar_system: sol,
      parent_body: nil,
      parent_celestial_body: nil,
      present?: true
    )
  end
  let(:luna) do
    double('Moon',
      name: 'Luna',
      star_system: sol,
      solar_system: sol,
      parent_body: earth,
      parent_celestial_body: earth,
      present?: true
    )
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