require 'rails_helper'

RSpec.describe Naming::PlanetNameService, type: :service do
  let(:service) { described_class.new }
  let(:data_path) { GalaxyGame::Paths::NAMES_PATH.join('planet_names.json') }

  before do
    # Ensure the data file exists for tests
    allow(File).to receive(:exist?).and_return(false) # Default
    allow(File).to receive(:exist?).with(data_path).and_return(true)
    allow(File).to receive(:read).with(data_path).and_return({
      "terraformed" => ["New Earth", "Nova Terra"],
      "neutral" => ["Aurelion", "Khepri"],
      "suffixes" => ["I", "II"]
    }.to_json)
  end

  describe '#initialize' do
    it 'loads name data from JSON file' do
      expect(service.instance_variable_get(:@names_data)).to be_a(Hash)
      expect(service.instance_variable_get(:@names_data)).to have_key('terraformed')
      expect(service.instance_variable_get(:@names_data)).to have_key('neutral')
    end

    it 'handles missing data file gracefully' do
      allow(File).to receive(:exist?).with(data_path).and_return(false)
      service = described_class.new
      expect(service.instance_variable_get(:@names_data)).to eq({})
    end
  end

  describe '#generate_planet_name' do
    it 'returns a terraformed name when terraformable is true' do
      allow(service).to receive(:find_unused_name).and_return("New Earth")
      allow(service).to receive(:unique?).and_return(true)

      name = service.generate_planet_name(terraformable: true, system_identifier: 'TEST', index: 1)

      expect(name).to eq("New Earth")
    end

    it 'returns a neutral name when terraformable is false' do
      allow(service).to receive(:find_unused_name).and_return("Aurelion")
      allow(service).to receive(:unique?).and_return(true)

      name = service.generate_planet_name(terraformable: false, system_identifier: 'TEST', index: 1)

      expect(name).to eq("Aurelion")
    end

    it 'adds suffix when name is not unique' do
      allow(service).to receive(:find_unused_name).and_return("Aurelion")
      allow(service).to receive(:unique?).and_return(false)
      allow(service).to receive(:add_suffix_to_name).and_return("Aurelion I")

      name = service.generate_planet_name(terraformable: false, system_identifier: 'TEST', index: 1)

      expect(service).to have_received(:add_suffix_to_name).with("Aurelion", 'TEST')
    end

    it 'marks name as used after generation' do
      allow(service).to receive(:find_unused_name).and_return("Aurelion")
      allow(service).to receive(:unique?).and_return(true)

      service.generate_planet_name(terraformable: false, system_identifier: 'TEST', index: 1)

      expect(service.instance_variable_get(:@used_names)).to include("Aurelion")
    end
  end

  describe '#find_unused_name' do
    it 'uses deterministic selection based on system and index' do
      names = ["Aurelion", "Khepri", "Talassa"]
      service.instance_variable_set(:@names_data, { 'neutral' => names })

      # For system 'TEST' (hash) + index 1
      name1 = service.send(:find_unused_name, names, 'TEST', 1)
      name2 = service.send(:find_unused_name, names, 'TEST', 1)

      expect(name1).to eq(name2) # Deterministic
      expect(names).to include(name1)
    end
  end

  describe '#add_suffix_to_name' do
    it 'adds a suffix to the base name' do
      service.instance_variable_set(:@names_data, { 'suffixes' => ['I', 'II'] })
      allow(Kernel).to receive(:rand).and_return(0) # First suffix

      result = service.send(:add_suffix_to_name, "Aurelion", 'TEST')

      expect(result).to eq("Aurelion I")
    end
  end

  describe '#unique?' do
    it 'returns true for unused names' do
      # Mock the Planet model
      planet_class = double('Planet')
      allow(planet_class).to receive(:exists?).and_return(false)
      stub_const('CelestialBodies::Planets::Planet', planet_class)

      expect(service.send(:unique?, "New Name")).to be true
    end

    it 'returns false for used names' do
      service.instance_variable_get(:@used_names) << "Used Name"

      expect(service.send(:unique?, "Used Name")).to be false
    end

    it 'checks database for existing planets' do
      planet_class = double('Planet')
      allow(planet_class).to receive(:exists?).with(name: "Existing Name").and_return(true)
      stub_const('CelestialBodies::Planets::Planet', planet_class)

      expect(service.send(:unique?, "Existing Name")).to be false
    end
  end
end