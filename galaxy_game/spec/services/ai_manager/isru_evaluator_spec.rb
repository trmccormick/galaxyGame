# spec/services/ai_manager/isru_evaluator_spec.rb
#
# Tests for ISRUEvaluator — rewired to live settlement models.
# Resource identifiers use chemical formulas (H2O, O2, CH4, CO2).
# Human-readable names are UI-layer only.

require 'rails_helper'

RSpec.describe AIManager::ISRUEvaluator do
  let(:celestial_body) { create(:celestial_body) }
  let(:location)       { create(:celestial_location, celestial_body: celestial_body) }
  let(:settlement)     { create(:base_settlement, location: location) }
  let(:evaluator)      { described_class.new(settlement) }

  # ── Shared setup helpers ──────────────────────────────────────────────────
  def add_solar_power(kw = 200)
    panels = (kw / 10.0).ceil  # solar_panel_array = 10 kW each
    create_list(:base_unit, panels,
                unit_type: 'SOLAR_PANEL_ARRAY',
                settlement: settlement,
                operational: true)
  end

  def setup_surface_storage(regolith_kg: 10_000)
    unless settlement.surface_storage
      settlement.inventory.create_surface_storage!(
        celestial_body: celestial_body,
        item_type: 'bulk'
      )
    end
    settlement.surface_storage.material_piles.find_or_create_by!(
      material_type: 'raw_regolith'
    ) { |p| p.amount = regolith_kg }
    settlement.surface_storage.material_piles
              .find_by(material_type: 'raw_regolith')
              &.update!(amount: regolith_kg)
  end

  def set_geosphere_volatiles(h2o_kg: 5000)
    celestial_body.geosphere.update!(
      stored_volatiles: { 'H2O' => { 'surface' => h2o_kg.to_f } }
    )
  end

  # ── #assess_capabilities ─────────────────────────────────────────────────
  describe '#assess_capabilities' do
    context 'with no ISRU units' do
      it 'returns operational status with low readiness and no regolith processing' do
        result = evaluator.assess_capabilities

        expect(result[:status]).to eq(:operational)
        expect(result[:overall_readiness]).to be < 0.3
        expect(result[:units_available]).to be_empty
        expect(result[:regolith_processing]).to be false
        expect(result[:atmospheric_processing]).to be false
      end
    end

    context 'with PVE only — TEU not required' do
      before do
        add_solar_power(200)
        setup_surface_storage(regolith_kg: 10_000)
        set_geosphere_volatiles(h2o_kg: 5000)
        create(:base_unit, unit_type: 'PLANETARY_VOLATILES_EXTRACTOR_MK1',
               settlement: settlement, operational: true)
      end

      it 'enables regolith processing without TEU' do
        result = evaluator.assess_capabilities

        expect(result[:status]).to eq(:operational)
        expect(result[:regolith_processing]).to be true
        expect(result[:teu_present]).to be false
        expect(result[:production_rates]['H2O']).to be > 0
        expect(result[:production_rates]['depleted_regolith']).to be > 0
      end
    end

    context 'with TEU + PVE — preferred full chain' do
      before do
        add_solar_power(200)
        setup_surface_storage(regolith_kg: 10_000)
        set_geosphere_volatiles(h2o_kg: 5000)
        create(:base_unit, unit_type: 'THERMAL_EXTRACTION_UNIT_MK1',
               settlement: settlement, operational: true)
        create(:base_unit, unit_type: 'PLANETARY_VOLATILES_EXTRACTOR_MK1',
               settlement: settlement, operational: true)
      end

      it 'shows TEU present and enables regolith processing' do
        result = evaluator.assess_capabilities

        expect(result[:status]).to eq(:operational)
        expect(result[:regolith_processing]).to be true
        expect(result[:teu_present]).to be true
        expect(result[:overall_readiness]).to be > 0.5
        expect(result[:production_rates]['H2O']).to be > 0
      end
    end

    context 'with insufficient power — hard gate' do
      before do
        # PVE requires 120 kW; no power units added
        create(:base_unit, unit_type: 'PLANETARY_VOLATILES_EXTRACTOR_MK1',
               settlement: settlement, operational: true)
      end

      it 'returns blocked status with insufficient_power reason' do
        result = evaluator.assess_capabilities

        expect(result[:status]).to eq(:blocked)
        expect(result[:reason]).to eq(:insufficient_power)
        expect(result[:power_capacity]).to be < result[:power_required]
      end

      it 'does not include production_rates when blocked' do
        result = evaluator.assess_capabilities

        expect(result).not_to have_key(:production_rates)
      end
    end

    context 'with CO2 atmosphere and gas conversion unit' do
      before do
        add_solar_power(200)
        celestial_body.atmosphere.gases.find_or_create_by!(name: 'CO2') do |g|
          g.percentage = 95.0
        end
        create(:base_unit, unit_type: 'GAS_CONVERSION_UNIT_DATA',
               settlement: settlement, operational: true)
      end

      it 'enables atmospheric gas processing from available atmosphere' do
        result = evaluator.assess_capabilities

        expect(result[:atmospheric_processing]).to be true
        expect(result[:atmospheric_inputs]).to be true
        # GCU: combined Sabatier+electrolysis — CO2 + 2H2O → CH4 + 2O2
        expect(result[:production_rates]['CH4']).to be > 0
        expect(result[:production_rates]['O2']).to be > 0
        # O2 output is ~4x CH4 by mass (276.36 vs 69.09 kg per cycle)
        expect(result[:production_rates]['O2']).to be > result[:production_rates]['CH4']
      end
    end

    context 'with geosphere CO2 stored volatiles' do
      before do
        celestial_body.geosphere.update!(
          stored_volatiles: { 'H2O' => { 'surface' => 3000.0 }, 'CO2' => { 'polar' => 2000.0 } }
        )
      end

      it 'reflects CO2 in resource_availability from geosphere' do
        result = evaluator.assess_capabilities

        expect(result[:resource_availability][:regolith_volatiles]['CO2']).to be_present
      end
    end
  end

  # ── #should_use_isru? ─────────────────────────────────────────────────────
  describe '#should_use_isru?' do
    context 'with PVE, sufficient power, and regolith' do
      before do
        add_solar_power(200)
        setup_surface_storage(regolith_kg: 10_000)
        set_geosphere_volatiles(h2o_kg: 50_000)
        create(:base_unit, unit_type: 'PLANETARY_VOLATILES_EXTRACTOR_MK1',
               settlement: settlement, operational: true)
      end

      it 'returns true for H2O — producible faster than import baseline' do
        expect(evaluator.should_use_isru?('H2O', 30, 30)).to be true
      end

      it 'returns false for an unknown compound with no production rate' do
        expect(evaluator.should_use_isru?('unobtainium', 100, 30)).to be false
      end
    end

    context 'with no ISRU units' do
      it 'returns false' do
        expect(evaluator.should_use_isru?('H2O', 100, 30)).to be false
      end
    end

    context 'with blocked power' do
      before do
        create(:base_unit, unit_type: 'PLANETARY_VOLATILES_EXTRACTOR_MK1',
               settlement: settlement, operational: true)
      end

      it 'returns false when power is insufficient' do
        expect(evaluator.should_use_isru?('H2O', 10, 30)).to be false
      end
    end
  end

  # ── #compare_isru_vs_import_cost ──────────────────────────────────────────
  describe '#compare_isru_vs_import_cost' do
    context 'with operational PVE and sufficient power' do
      before do
        add_solar_power(200)
        setup_surface_storage(regolith_kg: 10_000)
        set_geosphere_volatiles(h2o_kg: 5000)
        create(:base_unit, unit_type: 'PLANETARY_VOLATILES_EXTRACTOR_MK1',
               settlement: settlement, operational: true)
      end

      it 'returns cost comparison structure for H2O' do
        result = evaluator.compare_isru_vs_import_cost('H2O', 100)

        expect(result).to include(
          isru_cost:          be > 0,
          import_cost:        be > 0,
          recommended:        be_in(['isru', 'import']),
          savings_percentage: be_a(Numeric)
        )
      end

      it 'recommends ISRU for H2O (local production cheaper than import)' do
        result = evaluator.compare_isru_vs_import_cost('H2O', 100)

        expect(result[:recommended]).to eq('isru')
        expect(result[:savings_percentage]).to be > 0
      end
    end

    context 'without ISRU capability' do
      it 'recommends import when readiness is zero' do
        result = evaluator.compare_isru_vs_import_cost('H2O', 100)

        expect(result[:recommended]).to eq('import')
      end
    end
  end

  # ── #calculate_production_rates ───────────────────────────────────────────
  describe '#calculate_production_rates' do
    context 'with PVE and regolith volatiles' do
      before do
        setup_surface_storage(regolith_kg: 10_000)
        set_geosphere_volatiles(h2o_kg: 5000)
      end

      it 'returns H2O and depleted_regolith when PVE is present' do
        units = { 'PLANETARY_VOLATILES_EXTRACTOR_MK1' => 1 }
        resources = evaluator.send(:assess_resource_availability)

        rates = evaluator.calculate_production_rates(units, resources)

        expect(rates['H2O']).to be > 0
        expect(rates['depleted_regolith']).to be > 0
      end

      it 'uses DEFAULT_VOLATILE_FRACTION when geosphere has no stored volatiles' do
        celestial_body.geosphere.update!(stored_volatiles: {})
        setup_surface_storage(regolith_kg: 10_000)
        units = { 'PLANETARY_VOLATILES_EXTRACTOR_MK1' => 1 }
        resources = evaluator.send(:assess_resource_availability)

        rates = evaluator.calculate_production_rates(units, resources)

        # input_kg = 5.0 from PVE JSON; geo_eff = 0.75; volatile_fraction fallback = DEFAULT_VOLATILE_FRACTION
        expected_h2o = 5.0 * AIManager::ISRUEvaluator::DEFAULT_VOLATILE_FRACTION * 0.75 * 1
        expect(rates['H2O']).to be_within(0.01).of(expected_h2o)
      end

      it 'returns zero H2O when no raw_regolith in surface storage' do
        setup_surface_storage(regolith_kg: 0)
        units = { 'PLANETARY_VOLATILES_EXTRACTOR_MK1' => 1 }
        resources = evaluator.send(:assess_resource_availability)

        rates = evaluator.calculate_production_rates(units, resources)

        expect(rates['H2O']).to be_nil.or(eq(0))
      end
    end

    context 'with TEU adding processed_regolith production' do
      before do
        setup_surface_storage(regolith_kg: 10_000)
      end

      it 'produces processed_regolith from TEU' do
        units = { 'THERMAL_EXTRACTION_UNIT_MK1' => 1 }
        resources = evaluator.send(:assess_resource_availability)

        rates = evaluator.calculate_production_rates(units, resources)

        expect(rates['processed_regolith']).to be > 0
      end
    end
  end

  # ── private methods ───────────────────────────────────────────────────────
  describe 'private methods' do
    describe '#inventory_isru_units' do
      it 'counts only operational processing-capable units' do
        create(:base_unit, unit_type: 'THERMAL_EXTRACTION_UNIT_MK1',
               settlement: settlement, operational: true)
        create(:base_unit, unit_type: 'THERMAL_EXTRACTION_UNIT_MK1',
               settlement: settlement, operational: false)  # not counted
        create(:base_unit, unit_type: 'PLANETARY_VOLATILES_EXTRACTOR_MK1',
               settlement: settlement, operational: true)

        units = evaluator.send(:inventory_isru_units)

        expect(units['THERMAL_EXTRACTION_UNIT_MK1']).to eq(1)
        expect(units['PLANETARY_VOLATILES_EXTRACTOR_MK1']).to eq(1)
      end

      it 'excludes units with no matching JSON in UnitLookupService' do
        create(:base_unit, unit_type: 'NONEXISTENT_FAKE_UNIT_TYPE',
               settlement: settlement, operational: true)

        units = evaluator.send(:inventory_isru_units)

        expect(units).not_to have_key('NONEXISTENT_FAKE_UNIT_TYPE')
      end
    end

    describe '#assess_resource_availability' do
      it 'reads raw_regolith from surface_storage material_piles' do
        setup_surface_storage(regolith_kg: 5000)
        resources = evaluator.send(:assess_resource_availability)

        expect(resources[:raw_regolith]).to eq(5000.0)
      end

      it 'reads regolith_volatiles from geosphere stored_volatiles' do
        celestial_body.geosphere.update!(
          stored_volatiles: { 'H2O' => { 'surface' => 3000.0 } }
        )
        resources = evaluator.send(:assess_resource_availability)

        expect(resources[:regolith_volatiles]['H2O']).to include('surface' => 3000.0)
      end

      it 'reads atmospheric_gases from atmosphere.gases as name→percentage hash' do
        celestial_body.atmosphere.gases.find_or_create_by!(name: 'CO2') do |g|
          g.percentage = 95.0
        end
        resources = evaluator.send(:assess_resource_availability)

        expect(resources[:atmospheric_gases]['CO2']).to be_within(0.01).of(95.0)
      end

      it 'returns safe defaults when settlement has no celestial body' do
        settlement_no_body = create(:base_settlement, location: nil)
        eval_no_body = described_class.new(settlement_no_body)

        resources = eval_no_body.send(:assess_resource_availability)

        expect(resources[:regolith_volatiles]).to eq({})
        expect(resources[:atmospheric_gases]).to eq({})
      end
    end

    describe '#calculate_overall_readiness' do
      it 'returns a score between 0.0 and 1.0' do
        units      = { 'THERMAL_EXTRACTION_UNIT_MK1' => 1, 'PLANETARY_VOLATILES_EXTRACTOR_MK1' => 1 }
        resources  = { raw_regolith: 10_000.0, regolith_volatiles: {}, atmospheric_gases: {} }
        power      = 200.0
        required   = 170.0
        maintenance = { score: 1.0 }

        score = evaluator.send(:calculate_overall_readiness, units, resources, power, required, maintenance)

        expect(score).to be_between(0.0, 1.0)
      end

      it 'returns higher score with more units and full regolith stock' do
        units_full  = { 'PLANETARY_VOLATILES_EXTRACTOR_MK1' => 4 }
        units_empty = {}
        resources   = { raw_regolith: 10_000.0, regolith_volatiles: {}, atmospheric_gases: {} }
        maintenance = { score: 1.0 }

        full_score  = evaluator.send(:calculate_overall_readiness, units_full, resources, 200.0, 0.0, maintenance)
        empty_score = evaluator.send(:calculate_overall_readiness, units_empty, resources, 0.0, 0.0, maintenance)

        expect(full_score).to be > empty_score
      end
    end

    describe '#volatile_fraction' do
      it 'returns H2O fraction from stored_volatiles' do
        volatiles = { 'H2O' => { 'surface' => 80.0 }, 'CO2' => { 'polar' => 20.0 } }
        fraction = evaluator.send(:volatile_fraction, volatiles, 'H2O')

        expect(fraction).to be_within(0.001).of(0.8)
      end

      it 'returns DEFAULT_VOLATILE_FRACTION when stored_volatiles is empty' do
        fraction = evaluator.send(:volatile_fraction, {}, 'H2O')

        expect(fraction).to eq(AIManager::ISRUEvaluator::DEFAULT_VOLATILE_FRACTION)
      end

      it 'returns 0.0 when compound not present in survey data' do
        volatiles = { 'CO2' => { 'polar' => 100.0 } }
        fraction = evaluator.send(:volatile_fraction, volatiles, 'H2O')

        expect(fraction).to eq(0.0)
      end
    end
  end
end