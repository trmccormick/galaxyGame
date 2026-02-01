# spec/services/ai_manager/isru_evaluator_spec.rb
#
# Tests for ISRUEvaluator - ISRU capability assessment and prioritization

require 'rails_helper'

RSpec.describe AIManager::ISRUEvaluator do
  let(:settlement) { create(:base_settlement) }
  let(:evaluator) { described_class.new(settlement) }

  describe '#assess_capabilities' do
    context 'with no ISRU units' do
      it 'returns low readiness score' do
        capabilities = evaluator.assess_capabilities

        expect(capabilities[:overall_readiness]).to be < 0.3
        expect(capabilities[:units_available]).to be_empty
        expect(capabilities[:regolith_processing]).to be false
        expect(capabilities[:venus_compatible]).to be false
      end
    end

    context 'with TEU and PVE units' do
      before do
        create(:base_unit, unit_type: 'THERMAL_EXTRACTION_UNIT_MK1', settlement: settlement, operational: true)
        create(:base_unit, unit_type: 'PLANETARY_VOLATILES_EXTRACTOR_MK1', settlement: settlement, operational: true)
        create(:base_unit, unit_type: 'SOLAR_PANEL_ARRAY', settlement: settlement, operational: true)
        settlement.inventory.create_surface_storage!(celestial_body: settlement.celestial_body, item_type: 'bulk') unless settlement.surface_storage
        settlement.surface_storage.material_piles.create!(material_type: 'raw_regolith', amount: 10000)
        settlement.inventory.add_item('carbon_dioxide', 1000)
        settlement.inventory.add_item('water_ice', 200)
      end

      it 'enables regolith processing' do
        capabilities = evaluator.assess_capabilities

        expect(capabilities[:regolith_processing]).to be true
        expect(capabilities[:overall_readiness]).to be > 0.5
        expect(capabilities[:production_rates][:water]).to be > 0
      end

      it 'calculates production rates correctly' do
        capabilities = evaluator.assess_capabilities

        expect(capabilities[:production_rates]).to include(
          water: be > 0,
          inert_waste: be > 0
        )
      end
    end

    context 'with Venus-compatible units' do
      before do
        create(:base_unit, unit_type: 'CO2_SPLITTER_MK1', settlement: settlement, operational: true)
        create(:base_unit, unit_type: 'SOLAR_PANEL_ARRAY', settlement: settlement, operational: true)
        settlement.inventory.add_item('venus_atmosphere', 50000)
      end

      it 'enables Venus atmosphere processing' do
        capabilities = evaluator.assess_capabilities

        expect(capabilities[:venus_compatible]).to be true
        expect(capabilities[:production_rates][:liquid_oxygen]).to be > 0
      end
    end

    context 'with Sabatier reactor' do
      before do
        create(:base_unit, unit_type: 'SABATIER_REACTOR_MK1', settlement: settlement, operational: true)
        create(:base_unit, unit_type: 'SOLAR_PANEL_ARRAY', settlement: settlement, operational: true)
        # Add CO2 and H2 to inventory
        settlement.inventory.add_item('carbon_dioxide', 1000)
        settlement.inventory.add_item('hydrogen', 4000)
      end

      it 'enables methane production' do
        capabilities = evaluator.assess_capabilities

        expect(capabilities[:methane_generation]).to be true
        expect(capabilities[:production_rates][:methane]).to be > 0
        expect(capabilities[:production_rates][:water]).to be > 0
      end
    end
  end

  describe '#should_use_isru?' do
    context 'with sufficient ISRU capability' do
      before do
        create(:base_unit, unit_type: 'THERMAL_EXTRACTION_UNIT_MK1', settlement: settlement, operational: true)
        create(:base_unit, unit_type: 'PLANETARY_VOLATILES_EXTRACTOR_MK1', settlement: settlement, operational: true)
        1000.times { create(:base_unit, unit_type: 'SOLAR_PANEL_ARRAY', settlement: settlement, operational: true) }
        settlement.inventory.create_surface_storage!(celestial_body: settlement.celestial_body, item_type: 'bulk') unless settlement.surface_storage
        settlement.surface_storage.material_piles.create!(material_type: 'raw_regolith', amount: 10000)
        settlement.inventory.add_item('carbon_dioxide', 1000)
        settlement.inventory.add_item('water_ice', 500)
      end

      it 'returns true for water production' do
        result = evaluator.should_use_isru?('water', 30, 30)

        expect(result).to be true
      end

      it 'returns false for unavailable resources' do
        result = evaluator.should_use_isru?('unobtainium', 100, 30)

        expect(result).to be false
      end
    end

    context 'with insufficient ISRU capability' do
      it 'returns false' do
        result = evaluator.should_use_isru?('water', 100, 30)

        expect(result).to be false
      end
    end
  end

  describe '#compare_isru_vs_import_cost' do
    context 'with ISRU capability' do
      before do
        create(:base_unit, unit_type: 'THERMAL_EXTRACTION_UNIT_MK1', settlement: settlement, operational: true)
        create(:base_unit, unit_type: 'PLANETARY_VOLATILES_EXTRACTOR_MK1', settlement: settlement, operational: true)
      end

      it 'calculates cost comparison for water' do
        comparison = evaluator.compare_isru_vs_import_cost('water', 100)

        expect(comparison).to include(
          isru_cost: be > 0,
          import_cost: be > 0,
          recommended: be_in(['isru', 'import']),
          savings_percentage: be_a(Numeric)
        )
      end

      it 'recommends ISRU when cheaper' do
        comparison = evaluator.compare_isru_vs_import_cost('water', 100)

        expect(comparison[:recommended]).to eq('isru')
        expect(comparison[:savings_percentage]).to be > 0
      end
    end

    context 'without ISRU capability' do
      it 'recommends import' do
        comparison = evaluator.compare_isru_vs_import_cost('water', 100)

        expect(comparison[:recommended]).to eq('import')
      end
    end
  end

  describe '#calculate_production_rates' do
    context 'with full ISRU pipeline' do
      before do
        create(:base_unit, unit_type: 'THERMAL_EXTRACTION_UNIT_MK1', settlement: settlement, operational: true)
        create(:base_unit, unit_type: 'PLANETARY_VOLATILES_EXTRACTOR_MK1', settlement: settlement, operational: true)
        create(:base_unit, unit_type: 'CO2_SPLITTER_MK1', settlement: settlement, operational: true)
        create(:base_unit, unit_type: 'SABATIER_REACTOR_MK1', settlement: settlement, operational: true)

        # Add raw materials
        settlement.inventory.add_item('raw_regolith', 10000)
        settlement.inventory.add_item('venus_atmosphere', 50000)
        settlement.inventory.add_item('carbon_dioxide', 1000)
        settlement.inventory.add_item('hydrogen', 4000)
      end

      it 'calculates all production rates' do
        rates = evaluator.calculate_production_rates(
          { 'THERMAL_EXTRACTION_UNIT_MK1' => 1, 'PLANETARY_VOLATILES_EXTRACTOR_MK1' => 1, 'CO2_SPLITTER_MK1' => 1, 'SABATIER_REACTOR_MK1' => 1 },
          evaluator.send(:assess_resource_availability),
          200.0 # kW power
        )

        expect(rates[:water]).to be > 0
        expect(rates[:liquid_oxygen]).to be > 0
        expect(rates[:methane]).to be > 0
        expect(rates[:inert_waste]).to be > 0
      end

      it 'applies power limitations' do
        low_power_rates = evaluator.calculate_production_rates(
          { 'THERMAL_EXTRACTION_UNIT_MK1' => 1, 'PLANETARY_VOLATILES_EXTRACTOR_MK1' => 1 },
          evaluator.send(:assess_resource_availability),
          10.0 # kW - insufficient power
        )

        expect(low_power_rates[:water]).to be < 0.1 # Reduced due to power constraint
      end
    end
  end

  describe 'private methods' do
    describe '#inventory_isru_units' do
      it 'counts operational units by type' do
        create(:base_unit, unit_type: 'THERMAL_EXTRACTION_UNIT_MK1', settlement: settlement, operational: true)
        create(:base_unit, unit_type: 'THERMAL_EXTRACTION_UNIT_MK1', settlement: settlement, operational: false)
        create(:base_unit, unit_type: 'PLANETARY_VOLATILES_EXTRACTOR_MK1', settlement: settlement, operational: true)

        units = evaluator.send(:inventory_isru_units)

        expect(units['THERMAL_EXTRACTION_UNIT_MK1']).to eq(1)
        expect(units['PLANETARY_VOLATILES_EXTRACTOR_MK1']).to eq(1)
      end
    end

    describe '#assess_resource_availability' do
      before do
        # Ensure surface storage exists
        settlement.inventory.surface_storage || settlement.inventory.create_surface_storage!(
          celestial_body: settlement.celestial_body,
          item_type: 'bulk'
        )
        settlement.surface_storage.material_piles.create!(material_type: 'raw_regolith', amount: 5000)
        settlement.inventory.add_item('carbon_dioxide', 1000)
        settlement.inventory.add_item('water_ice', 200)
      end

      it 'returns resource availability hash' do
        resources = evaluator.send(:assess_resource_availability)

        expect(resources[:raw_regolith]).to eq(5000)
        expect(resources[:co2]).to eq(1000)
        expect(resources[:ice]).to eq(200)
      end
    end

    describe '#calculate_overall_readiness' do
      it 'calculates weighted readiness score' do
        units = { 'THERMAL_EXTRACTION_UNIT_MK1' => 1, 'PLANETARY_VOLATILES_EXTRACTOR_MK1' => 1 }
        resources = { raw_regolith: 10000, co2: 1000, ice: 500 }
        power = 150.0
        maintenance = { score: 1.0 }

        score = evaluator.send(:calculate_overall_readiness, units, resources, power, maintenance)

        expect(score).to be_between(0.0, 1.0)
      end
    end
  end
end