# spec/models/craft/satellite/base_satellite_spec.rb
require 'rails_helper'
require 'units/base_unit' # ✅ ADDED: Explicitly require the associated model

RSpec.describe Craft::Satellite::BaseSatellite, type: :model do
  # --- Setup Common Test Data ---
  let!(:celestial_body) { create(:large_moon, :luna) }
  # ✅ CORRECTED: Use your existing :player factory for the owner
  let!(:owner) { create(:player) }

  # A specific celestial location for testing
  let!(:lunar_orbit_location) do
    create(:celestial_location,
      name: "Lunar Orbit",
      coordinates: "0.00°N 0.00°E",
      celestial_body: celestial_body
    )
  end

  before(:each) do
    # Create a default stub for CraftLookupService that responds to any craft_type
    lookup_service = instance_double(Lookup::CraftLookupService)
    allow(Lookup::CraftLookupService).to receive(:new).and_return(lookup_service)
    allow(lookup_service).to receive(:find_craft).and_return({
      "name" => "Default Satellite",
      "craft_type" => "default_satellite",
      "recommended_units" => []
    })
    
    # Create a default stub for UnitLookupService
    unit_lookup_service = instance_double(Lookup::UnitLookupService)
    allow(Lookup::UnitLookupService).to receive(:new).and_return(unit_lookup_service)
    allow(unit_lookup_service).to receive(:find_unit) do |unit_id|
      { "id" => unit_id, "name" => unit_id.humanize }
    end
  end

  # --- Satellite Definitions ---

  # Setup for a satellite with specific deployment locations defined in its operational data
  let!(:satellite_with_specific_deployment_data) do
    craft = create(:base_satellite,
      name: "Specific Deployment Satellite",
      craft_name: "specific_deployment_satellite",
      craft_type: "specific_deployment_satellite",
      owner: owner,
      operational_data: {
        "name" => "Specific Deployment Satellite",
        "craft_type" => "specific_deployment_satellite",
        "recommended_units" => [],
        "deployment" => {
          "deployment_locations" => ["orbital", "high_orbital", "wormhole_proximity"]
        }
      }
    )
    
    craft.build_units_and_modules
    craft.save!
    craft
  end

  # Setup for a satellite that relies on the generic space-based deployment locations
  let!(:satellite_with_generic_deployment_data) do
    craft = create(:base_satellite,
      name: "Generic Space Satellite",
      craft_name: "generic_space_satellite",
      craft_type: "generic_space_satellite",
      owner: owner,
      operational_data: {
        "name" => "Generic Space Satellite",
        "craft_type" => "generic_space_satellite",
        "recommended_units" => []
        # No deployment locations specified - will use default space locations
      }
    )
    
    craft.build_units_and_modules
    craft.save!
    craft
  end

  # Setup for a satellite with recommended units
  let!(:satellite_with_recommended_units) do
    craft = create(:base_satellite,
      name: "Unit Test Satellite",
      craft_name: "unit_test_satellite",
      craft_type: "unit_test_satellite",
      owner: owner,
      operational_data: {
        "name" => "Unit Test Satellite",
        "craft_type" => "unit_test_satellite",
        "recommended_units" => [
          { "id" => "basic_computer", "count" => 1 },
          { "id" => "solar_panels", "count" => 1 },
          { "id" => "basic_sensor", "count" => 1 }
        ]
      }
    )
    
    craft.build_units_and_modules
    craft.save!
    craft
  end

  # --- Test Suites ---

  describe 'associations and basic attributes' do
    let(:satellite) { satellite_with_specific_deployment_data }

    before do
      satellite.set_location(lunar_orbit_location)
      satellite.save!
      satellite.create_inventory! unless satellite.inventory.present?
    end

    it 'has the correct current location string' do
      expect(satellite.current_location).to eq('Lunar Orbit')
    end

    it 'can access its location helper' do
      expect(satellite.location).to eq(lunar_orbit_location)
    end

    it '#needs_atmosphere? returns false for satellites' do
      expect(satellite.needs_atmosphere?).to be false
    end
  end

  describe '#valid_deployment_location?' do
    context 'when operational data defines specific deployment locations' do
      let(:satellite) { satellite_with_specific_deployment_data }

      it 'permits locations defined in its operational data' do
        expect(satellite.valid_deployment_location?('orbital')).to be true
        expect(satellite.valid_deployment_location?('high_orbital')).to be true # Changed from lunar_orbit
        expect(satellite.valid_deployment_location?('wormhole_proximity')).to be true
      end

      it 'rejects locations not defined in its operational data, even if generally space-based' do
        expect(satellite.valid_deployment_location?('deep_space')).to be false
        expect(satellite.valid_deployment_location?('lagrangian_point')).to be false
      end

      it 'rejects clearly non-space deployment locations' do
        expect(satellite.valid_deployment_location?('planetary_surface')).to be false
        expect(satellite.valid_deployment_location?('deep_sea')).to be false
      end
    end

    context 'when operational data does NOT define specific deployment locations' do
      let(:satellite) { satellite_with_generic_deployment_data }

      it 'permits general space-based locations from BaseSatellite fallback list' do
        expect(satellite.valid_deployment_location?('orbital')).to be true
        expect(satellite.valid_deployment_location?('high_orbital')).to be true
        expect(satellite.valid_deployment_location?('deep_space')).to be true
        expect(satellite.valid_deployment_location?('lagrangian_point')).to be true
        expect(satellite.valid_deployment_location?('wormhole_proximity')).to be true
      end

      it 'rejects clearly non-space deployment locations' do
        expect(satellite.valid_deployment_location?('planetary_surface')).to be false
        expect(satellite.valid_deployment_location?('ocean_floor')).to be false
        expect(satellite.valid_deployment_location?('underground')).to be false
      end
    end
  end

  describe '#deploy' do
    let(:satellite) { satellite_with_specific_deployment_data }

    it 'updates location string and deployment status if valid' do
      expect(satellite.deployed).to be false
      satellite.deploy('orbital')
      expect(satellite.current_location).to eq('orbital')
      expect(satellite.deployed).to be true
    end

    it 'raises if given invalid deployment location string' do
      expect { satellite.deploy('ocean_floor') }.to raise_error("Invalid deployment location")
    end
  end

  describe 'unit loading' do
    it 'installs the correct recommended units' do
      expect(satellite_with_specific_deployment_data.base_units.map(&:unit_type)).to be_empty
    end

    context 'when recommended units are specified in operational data' do
      it 'installs the correct recommended units' do
        expect(satellite_with_recommended_units.base_units.map(&:unit_type)).to include('basic_computer', 'solar_panels', 'basic_sensor')
        expect(satellite_with_recommended_units.base_units.count).to eq(3)
      end
    end
  end
end