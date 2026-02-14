
require 'rails_helper'
require 'json'

RSpec.describe Lookup::UnitLookupService do
  # Create a fresh service instance for each test context
  let(:service) { described_class.new }

  describe '#find_unit' do
    it 'loads units from the correct file structure' do
      units_base_path = GalaxyGame::Paths::UNITS_PATH
      expect(File.directory?(units_base_path)).to be true

      propulsion_path = GalaxyGame::Paths::PROPULSION_UNITS_PATH
      expect(File.directory?(propulsion_path)).to be true

      habitats_path = GalaxyGame::Paths::HABITATS_UNITS_PATH
      expect(File.directory?(habitats_path)).to be true
    end

    it 'loads units successfully' do
      expect(service.instance_variable_get(:@units)).to be_present
      expect(service.instance_variable_get(:@units).count).to be > 0
    end

    it 'finds propulsion files' do
      propulsion_files = Dir.glob(GalaxyGame::Paths::PROPULSION_UNITS_PATH.join('**', '*.json'))
      expect(propulsion_files).to be_present
      expect(propulsion_files.count).to be > 0
    end

    context 'with propulsion units' do
      let(:propulsion_files) { Dir.glob(GalaxyGame::Paths::PROPULSION_UNITS_PATH.join('**', '*.json')) }
      before do
        skip "No propulsion unit files found" if propulsion_files.empty?
      end
      it 'finds propulsion units by their exact ID' do
        unit_data = JSON.parse(File.read(propulsion_files.first))
        unit_id = unit_data['id']
        found_unit = service.find_unit(unit_id)
        expect(found_unit).to be_present,
          "Unit #{unit_id} not found. Check if '#{File.basename(propulsion_files.first)}' exists"
        expect(found_unit["id"]).to eq(unit_id)
        expect(found_unit["category"]).to match(/propulsion/i)
      end
      it 'has expected propulsion unit properties' do
        unit_data = JSON.parse(File.read(propulsion_files.first))
        unit_id = unit_data['id']
        propulsion_unit = service.find_unit(unit_id)
        expect(propulsion_unit).to be_present
        if propulsion_unit.dig("performance", "nominal_thrust_kn")
          expect(propulsion_unit.dig("performance", "nominal_thrust_kn")).to be_a(Numeric)
        end
      end
    end
    context 'with habitat units' do
      let(:habitat_files) { Dir.glob(GalaxyGame::Paths::HABITATS_UNITS_PATH.join('**', '*.json')) }
      before do
        skip "No habitat unit files found" if habitat_files.empty?
      end
      it 'finds habitat units by their ID' do
        unit_data = JSON.parse(File.read(habitat_files.first))
        unit_id = unit_data['id']
        habitat_unit = service.find_unit(unit_id)
        expect(habitat_unit).to be_present,
          "Unit #{unit_id} not found. Check if '#{File.basename(habitat_files.first)}' exists"
        expect(habitat_unit['id']).to eq(unit_id)
        expect(habitat_unit['category']).to match(/habitat/i)
      end
    end
    context 'with robot units' do
      let(:robot_files) { Dir.glob(GalaxyGame::Paths::ROBOTS_DEPLOYMENT_UNITS_PATH.join('**', '*.json')) }
      before do
        skip "No robot deployment unit files found" if robot_files.empty?
      end
      it 'finds robot units by their ID' do
        unit_data = JSON.parse(File.read(robot_files.first))
        unit_id = unit_data['id']
        robot_unit = service.find_unit(unit_id)
        expect(robot_unit).to be_present,
          "Robot unit #{unit_id} not found. Check its JSON file in #{GalaxyGame::Paths::ROBOTS_DEPLOYMENT_UNITS_PATH}"
        expect(robot_unit['id']).to eq(unit_id)
        expect(robot_unit['category']).to match(/robot/i)
      end
    end
    it 'finds units case-insensitively by ID' do
      all_unit_files = Dir.glob(GalaxyGame::Paths::UNITS_PATH.join('**', '*.json'))
      skip "No unit files found" if all_unit_files.empty?
      unit_data = JSON.parse(File.read(all_unit_files.first))
      unit_id = unit_data['id']
      unit_upper = service.find_unit(unit_id.upcase)
      expect(unit_upper).to be_present
      expect(unit_upper['id']).to eq(unit_id)
    end
    it 'returns nil for nonexistent units' do
      expect(service.find_unit("nonexistent_unit_xyz_12345")).to be_nil
    end
    it 'handles nil and blank unit queries gracefully' do
      expect(service.find_unit(nil)).to be_nil
      expect(service.find_unit("")).to be_nil
      expect(service.find_unit("   ")).to be_nil
    end
  end

  describe 'service configuration' do
    it 'has all expected unit categories' do
      expected_categories = %w[
        computer droid energy habitats life_support processing production propulsion 
        storage structure specialized communication construction control em_processing
        gravitational_control infrastructure power resource sensors
        robots_deployment robots_construction robots_maintenance robots_exploration 
        robots_life_support robots_logistics robots_resource
      ]
      actual_categories = described_class::UNIT_PATHS.keys.map(&:to_s)
      expect(actual_categories).to match_array(expected_categories)
    end
  end

  describe 'unit data structure validation' do
    context 'when any propulsion unit exists' do
      let(:propulsion_unit) do
        # Use a known unit id instead of reading from file
        service.find_unit('basic_engine')
      end
      it 'finds a propulsion unit' do
        propulsion_unit = service.find_unit('basic_engine')
        expect(propulsion_unit).to be_present, "No propulsion units found"
      end
      it 'has all expected top-level unit properties' do
        expected_properties = %w[id name category template]
        expected_properties.each do |prop|
          expect(propulsion_unit).to have_key(prop), "Expected unit to have key '#{prop}'"
        end
      end
      it 'has performance properties if applicable' do
        if propulsion_unit['performance']
          expect(propulsion_unit['performance']).to be_a(Hash)
        end
      end
      it 'has operational properties' do
        if propulsion_unit['operational_properties']
          expect(propulsion_unit['operational_properties']).to be_a(Hash)
          if propulsion_unit.dig('operational_properties', 'status')
            expect(propulsion_unit.dig('operational_properties', 'status')).to be_a(String)
          end
        end
      end
      it 'has maintenance requirements if defined' do
        if propulsion_unit['maintenance_requirements']
          expect(propulsion_unit['maintenance_requirements']).to be_a(Hash)
        end
      end
      it 'has operational modes if defined' do
        if propulsion_unit['operational_modes']
          expect(propulsion_unit['operational_modes']).to be_a(Hash)
          if propulsion_unit.dig('operational_modes', 'available_modes')
            expect(propulsion_unit.dig('operational_modes', 'available_modes')).to be_a(Array)
          end
        end
      end
      it 'has telemetry metadata if defined' do
        if propulsion_unit['telemetry']
          expect(propulsion_unit['telemetry']).to be_a(Hash)
        end
      end
    end
    context 'when any storage unit exists' do
      let(:storage_unit) do
        # Use a known unit id instead of reading from file
        service.find_unit('fuel_tank_s')
      end
      it 'finds a storage unit' do
        expect(storage_unit).to be_present, "No storage units found"
      end
      it 'has storage capacity properties' do
        if storage_unit['storage']
          expect(storage_unit['storage']).to be_a(Hash)
          if storage_unit.dig('storage', 'capacity')
            expect(storage_unit.dig('storage', 'capacity')).to be_a(Numeric)
          end
        end
      end
      it 'has alias support if defined' do
        if storage_unit['aliases'].present?
          expect(storage_unit['aliases']).to be_a(Array)
        end
      end
    end
  end

  describe 'matching behavior' do
    let(:any_unit_file) { Dir.glob(GalaxyGame::Paths::UNITS_PATH.join('**', '*.json')).first }
    let(:unit_data) { JSON.parse(File.read(any_unit_file)) if any_unit_file }
    before do
      skip "No unit files found" unless unit_data
    end
    it 'matches by exact ID' do
      result = service.find_unit(unit_data['id'])
      expect(result).to be_present
      expect(result['id']).to eq(unit_data['id'])
    end
    it 'matches by exact name' do
      result = service.find_unit(unit_data['name'])
      expect(result).to be_present
    end
    it 'matches by partial ID with sufficient length' do
      unit_id = unit_data['id']
      skip "Unit ID too short" if unit_id.length < 6
      partial = unit_id[0..3]
      result = service.find_unit(partial)
      expect(result).to be_present
    end
    it 'is case insensitive' do
      result = service.find_unit(unit_data['id'].upcase)
      expect(result).to be_present
      expect(result['id']).to eq(unit_data['id'])
    end
  end

  describe '#debug_paths' do
    it 'outputs path information without errors' do
      expect { service.debug_paths }.not_to raise_error
    end
  end
end