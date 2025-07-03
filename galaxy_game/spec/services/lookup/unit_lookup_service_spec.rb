require 'rails_helper'
require 'json'

RSpec.describe Lookup::UnitLookupService do
  # Memoize the service instance to avoid reloading data for every test
  # This relies on the service's initialize method to load data
  let(:service) { described_class.new }

  # ✅ REMOVED: The before(:all) hook is typically not needed if the service's
  # initialize method handles data loading. If load_all_unit_data was a
  # custom, separate loading mechanism, it should be clarified or removed
  # in favor of the initialize method's loading.
  # Assuming the service's `initialize` properly loads data, this is redundant.
  # before(:all) do
  #   Lookup::UnitLookupService.send(:load_all_unit_data) if Lookup::UnitLookupService.private_methods.include?(:load_all_unit_data)
  # end

  describe '#find_unit' do
    it 'loads units from the correct file structure' do
      # Use the specific path constant from GalaxyGame::Paths for consistency
      units_base_path = GalaxyGame::Paths::UNITS_PATH
      
      # Corrected: RSpec's 'be true' matcher does not accept a custom message directly.
      # The default failure message is usually sufficient and helpful.
      expect(File.directory?(units_base_path)).to be true

      propulsion_path = GalaxyGame::Paths::PROPULSION_UNITS_PATH # Use the specific constant
      expect(File.directory?(propulsion_path)).to be true

      # ✅ ADDED: Verify the habitats path also exists
      habitats_path = GalaxyGame::Paths::HABITATS_UNITS_PATH
      expect(File.directory?(habitats_path)).to be true
    end

    it 'finds units by their exact ID' do
      raptor_engine = service.find_unit("raptor_engine")
      expect(raptor_engine).to be_present,
        "raptor_engine unit not found. Check if 'raptor_engine_data.json' exists at " \
        "#{GalaxyGame::Paths::PROPULSION_UNITS_PATH.join('raptor_engine_data.json')}" # Use specific path constant
      
      expect(raptor_engine["id"]).to eq("raptor_engine")
      expect(raptor_engine["name"]).to eq("Raptor Engine Operational Data")
      expect(raptor_engine["category"]).to eq("propulsion")

      expect(raptor_engine.dig("performance", "nominal_thrust_kn")).to be_a(Numeric)
    end

    it 'finds the small_habitat unit by its ID' do
      # This test requires app/data/operational_data/units/habitats/small_habitat_data.json to exist
      small_habitat_unit = service.find_unit("small_habitat")
      
      expect(small_habitat_unit).to be_present,
        "small_habitat unit not found. Check if 'small_habitat_data.json' exists at " \
        "#{GalaxyGame::Paths::HABITATS_UNITS_PATH.join('small_habitat_data.json')}" # ✅ FIX: Use correct plural path and constant
      
      expect(small_habitat_unit['id']).to eq('small_habitat')
      expect(small_habitat_unit['name']).to eq('Small Habitat') 
      expect(small_habitat_unit['category']).to eq('habitats') # ✅ FIX: Category should be 'habitats' (plural)
    end

    it 'finds units case-insensitively by ID or alias' do
      raptor_engine_upper = service.find_unit("RAPTOR_ENGINE")
      expect(raptor_engine_upper).to be_present
      expect(raptor_engine_upper['id']).to eq('raptor_engine')

      lox_tank_alias = service.find_unit("LOX_TANK")
      expect(lox_tank_alias).to be_present
      expect(lox_tank_alias['id']).to eq('lox_storage_tank') # Actual ID from lox_storage_tank.json
    end

    # ✅ ADDED: Test for a robot unit
    it 'finds a robot unit by its ID' do
      # Using 'car_300_deployment_robot_mk1' as confirmed by your logs
      car_300_robot = service.find_unit("car_300_deployment_robot_mk1")
      expect(car_300_robot).to be_present,
        "car_300_deployment_robot_mk1 unit not found. Check its JSON file in #{GalaxyGame::Paths::ROBOTS_DEPLOYMENT_UNITS_PATH}"
      expect(car_300_robot['id']).to eq('car_300_deployment_robot_mk1')
      # Assuming the category in its JSON is 'robots_deployment'
      expect(car_300_robot['category']).to eq('robots_deployment')
    end

    it 'returns nil for nonexistent units' do
      expect(service.find_unit("nonexistent_unit")).to be_nil
    end

    it 'handles nil and blank unit queries gracefully' do
      expect(service.find_unit(nil)).to be_nil
      expect(service.find_unit("")).to be_nil
      expect(service.find_unit("   ")).to be_nil
    end
  end

  describe 'service configuration' do
    # ✅ REMOVED: base_units_path method no longer exists in UnitLookupService
    # it 'has the correct base path' do
    #   expected_path = GalaxyGame::Paths::UNITS_PATH.to_s
    #   actual_path = described_class.base_units_path.to_s
    #   expect(actual_path).to eq(expected_path)
    # end
    
    it 'has all expected unit categories' do
      # ✅ FIX: Updated expected_categories to include robots and correctly pluralize habitats
      expected_categories = %w[
        computer droid energy habitats life_support processing production propulsion 
        storage structure specialized 
        robots_deployment robots_construction robots_maintenance robots_exploration 
        robots_life_support robots_logistics robots_resource
      ]
      actual_categories = described_class::UNIT_PATHS.keys.map(&:to_s)
      expect(actual_categories).to match_array(expected_categories)
    end
  end

  describe 'unit data structure validation' do
    context 'when raptor_engine unit exists' do
      let(:raptor_engine) { service.find_unit("raptor_engine") }
      
      it 'has all expected top-level unit properties' do
        expect(raptor_engine).to be_present # Ensure unit is found
        expected_properties = %w[id name description category template]
        expected_properties.each do |prop|
          expect(raptor_engine).to have_key(prop), "Expected raptor_engine to have key '#{prop}'"
        end
      end
      
      it 'has correct performance and resource properties' do
        expect(raptor_engine).to be_present
        expect(raptor_engine.dig("performance", "nominal_thrust_kn")).to be_a(Numeric)
        expect(raptor_engine.dig("performance", "nominal_specific_impulse_s")).to be_a(Numeric)
        
        expect(raptor_engine.dig("resource_management", "input_resources")).to be_a(Array)
        expect(raptor_engine.dig("resource_management", "output_resources")).to be_a(Array)
      end
      
      it 'follows the operational data template structure' do
        expect(raptor_engine).to be_present
        expect(raptor_engine['operational_properties']).to be_present
        expect(raptor_engine['operational_properties']['power_draw_kw']).to be_a(Numeric)
        expect(raptor_engine['operational_properties']['heat_generation_kw']).to be_a(Numeric)
        expect(raptor_engine['operational_properties']['status']).to be_a(String)
        expect(raptor_engine['operational_properties']['condition_percent']).to be_a(Numeric)
      end

      it 'has correct maintenance and connection requirements' do
        expect(raptor_engine).to be_present
        expect(raptor_engine['maintenance_requirements']).to be_present
        expect(raptor_engine['maintenance_requirements']['time_to_repair_hours']).to be_a(Numeric)
        expect(raptor_engine['maintenance_requirements']['materials_needed_for_repair']).to be_a(Array)

        expect(raptor_engine['connections_required']).to be_present
        expect(raptor_engine['connections_required']['fuel_line_count']).to be_a(Numeric)
      end

      it 'has defined operational modes and diagnostics' do
        expect(raptor_engine).to be_present
        expect(raptor_engine['operational_modes']).to be_present
        expect(raptor_engine['operational_modes']['available_modes']).to be_a(Array)
        expect(raptor_engine['operational_modes']['available_modes'].first).to have_key('name')

        expect(raptor_engine['diagnostics']).to be_present
        expect(raptor_engine['diagnostics']['temperature_k']).to have_key('combustion_chamber')
      end

      it 'has telemetry metadata' do
        expect(raptor_engine).to be_present
        expect(raptor_engine['telemetry']).to be_present
        expect(raptor_engine['telemetry']['data_points']).to be_a(Array)
        expect(raptor_engine['telemetry']['logging_frequency_hz']).to be_a(Numeric)
      end
    end

    context 'when lox_storage_tank unit exists' do
      let(:lox_tank) { service.find_unit("lox_storage_tank") }
      
      it 'has storage capacity properties' do
        expect(lox_tank).to be_present
        expect(lox_tank['storage']).to be_present
        expect(lox_tank['storage']['capacity']).to be_a(Numeric)
      end

      it 'has alias support if defined' do
        expect(lox_tank).to be_present
        if lox_tank['aliases'].present?
          expect(lox_tank['aliases']).to be_a(Array)
          expect(lox_tank['aliases']).to include('lox_tank')
        else
          pending "lox_storage_tank does not have 'aliases' defined in its JSON."
        end
      end
    end
  end
end