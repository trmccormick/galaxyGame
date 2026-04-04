# spec/services/ai_manager/isru_optimizer_spec.rb
#
# Tests for IsruOptimizer — rewired to Market::Order buy queue + ISRUEvaluator.
# No target_system or settlement_plan hashes. Uses instance doubles throughout.
# Resource identifiers use chemical formulas (H2O, O2, CH4, CO2, N2).

require 'rails_helper'

RSpec.describe AIManager::IsruOptimizer do
  let(:shared_context) { {} }
  let(:optimizer)      { described_class.new(shared_context) }
  let(:settlement)     { instance_double('Settlement::BaseSettlement') }

  # ── Helpers ──────────────────────────────────────────────────────────────

  def order_for(resource)
    order = instance_double('Market::Order', resource: resource)
    allow(order).to receive(:fulfilled?).and_return(false)
    allow(order).to receive(:expired?).and_return(false)
    order
  end

  def stub_orders(*orders)
    scope = double('buy_scope')
    allow(Market::Order).to receive(:where)
      .with(base_settlement: settlement)
      .and_return(scope)
    allow(scope).to receive(:buy).and_return(orders)
  end

  def stub_capabilities(caps)
    evaluator_double = instance_double(
      'AIManager::ISRUEvaluator',
      assess_capabilities: caps
    )
    allow(AIManager::ISRUEvaluator).to receive(:new)
      .with(settlement)
      .and_return(evaluator_double)
  end

  # Full-capability hash — all phases satisfied, plenty of regolith
  let(:full_capabilities) do
    {
      status:                :operational,
      teu_present:           true,
      regolith_processing:   true,
      methane_generation:    true,
      atmospheric_processing: true,
      atmospheric_inputs:    true,
      resource_availability: { raw_regolith: 5000.0 },
      production_rates:      { 'H2O' => 0.1, 'CH4' => 0.05, 'O2' => 0.22 },
      overall_readiness:     0.90,
      recommendations:       []
    }
  end

  # ── #optimize_isru_priorities ─────────────────────────────────────────────

  describe '#optimize_isru_priorities' do
    context 'when there are no unfilled buy orders' do
      before { stub_orders }   # empty

      it 'returns no_unfilled_orders without calling evaluator' do
        expect(AIManager::ISRUEvaluator).not_to receive(:new)
        result = optimizer.optimize_isru_priorities(settlement)
        expect(result).to eq({ phases: [], reason: :no_unfilled_orders })
      end
    end

    context 'when evaluator reports insufficient power' do
      let(:blocked_caps) do
        {
          status:          :blocked,
          reason:          :insufficient_power,
          power_capacity:  10.0,
          power_required:  40.0,
          recommendations: ['Expand power generation — need 30.0 kW more']
        }
      end

      before do
        stub_orders(order_for('H2O'))
        stub_capabilities(blocked_caps)
      end

      it 'passes the blocked result through directly' do
        result = optimizer.optimize_isru_priorities(settlement)
        expect(result[:status]).to eq(:blocked)
        expect(result[:reason]).to eq(:insufficient_power)
        expect(result[:power_required]).to eq(40.0)
      end
    end

    context 'when all ordered compounds are already being produced' do
      before do
        stub_orders(order_for('H2O'))
        stub_capabilities(full_capabilities)
      end

      it 'returns all_satisfied with current production rates' do
        result = optimizer.optimize_isru_priorities(settlement)
        expect(result[:phases]).to be_empty
        expect(result[:reason]).to eq(:all_satisfied)
        expect(result[:production_rates]).to eq(full_capabilities[:production_rates])
      end
    end

    context 'when raw regolith stock is below 100 kg' do
      before do
        stub_orders(order_for('H2O'))
        stub_capabilities(full_capabilities.merge(
          resource_availability: { raw_regolith: 50.0 }
        ))
      end

      it 'includes phase 2 (regolith supply)' do
        result = optimizer.optimize_isru_priorities(settlement)
        expect(result[:phases].map { |p| p[:name] }).to include(:regolith_supply)
      end

      it 'phase 2 sorts before other phases' do
        result = optimizer.optimize_isru_priorities(settlement)
        first_phase_number = result[:phases].first[:phase]
        expect(first_phase_number).to eq(2)
      end
    end

    context 'when TEU is not present' do
      before do
        stub_orders(order_for('H2O'))
        stub_capabilities(full_capabilities.merge(teu_present: false))
      end

      it 'includes phase 3 (thermal extraction)' do
        result = optimizer.optimize_isru_priorities(settlement)
        expect(result[:phases].map { |p| p[:name] }).to include(:thermal_extraction)
      end

      it 'does not include gas conversion — only H2O ordered' do
        result = optimizer.optimize_isru_priorities(settlement)
        expect(result[:phases].map { |p| p[:name] }).not_to include(:gas_conversion)
      end
    end

    context 'when PVE (volatile separation) is not operational' do
      before do
        stub_orders(order_for('H2O'))
        stub_capabilities(full_capabilities.merge(regolith_processing: false))
      end

      it 'includes phase 4 (volatile separation)' do
        result = optimizer.optimize_isru_priorities(settlement)
        expect(result[:phases].map { |p| p[:name] }).to include(:volatile_separation)
      end
    end

    context 'when CH4 is ordered but GCU is not operational' do
      before do
        stub_orders(order_for('CH4'))
        stub_capabilities(full_capabilities.merge(methane_generation: false))
      end

      it 'includes phase 5 (gas conversion)' do
        result = optimizer.optimize_isru_priorities(settlement)
        expect(result[:phases].map { |p| p[:name] }).to include(:gas_conversion)
      end
    end

    context 'when O2 is ordered but GCU is not operational' do
      before do
        stub_orders(order_for('O2'))
        stub_capabilities(full_capabilities.merge(methane_generation: false))
      end

      it 'includes phase 5 (gas conversion) — GCU produces O2 via integrated electrolysis' do
        result = optimizer.optimize_isru_priorities(settlement)
        expect(result[:phases].map { |p| p[:name] }).to include(:gas_conversion)
      end
    end

    context 'when H2O is ordered but GCU is absent' do
      before do
        stub_orders(order_for('H2O'))
        stub_capabilities(full_capabilities.merge(methane_generation: false))
      end

      it 'does not include gas conversion — H2O is produced by PVE, not GCU' do
        result = optimizer.optimize_isru_priorities(settlement)
        expect(result[:phases].map { |p| p[:name] }).not_to include(:gas_conversion)
      end

      it 'returns all_satisfied because regolith_processing is true and PVE covers H2O' do
        result = optimizer.optimize_isru_priorities(settlement)
        expect(result[:reason]).to eq(:all_satisfied)
      end
    end

    context 'when the full ISRU chain is needed' do
      before do
        stub_orders(order_for('CH4'), order_for('H2O'))
        stub_capabilities({
          status:                :operational,
          teu_present:           false,
          regolith_processing:   false,
          methane_generation:    false,
          atmospheric_processing: false,
          atmospheric_inputs:    false,
          resource_availability: { raw_regolith: 0.0 },
          production_rates:      {},
          overall_readiness:     0.0,
          recommendations:       ['Deploy thermal extraction unit', 'Deploy volatile extractor']
        })
      end

      it 'returns phases 2 through 5 in ascending order' do
        result = optimizer.optimize_isru_priorities(settlement)
        phase_numbers = result[:phases].map { |p| p[:phase] }
        expect(phase_numbers).to eq([2, 3, 4, 5])
      end

      it 'includes all demanded compounds in result' do
        result = optimizer.optimize_isru_priorities(settlement)
        expect(result[:demanded]).to contain_exactly('CH4', 'H2O')
      end

      it 'includes production rates and readiness from evaluator' do
        result = optimizer.optimize_isru_priorities(settlement)
        expect(result[:production_rates]).to eq({})
        expect(result[:overall_readiness]).to eq(0.0)
        expect(result[:recommendations]).not_to be_empty
      end

      it 'each phase includes description' do
        result = optimizer.optimize_isru_priorities(settlement)
        result[:phases].each do |phase|
          expect(phase[:description]).to be_present
        end
      end
    end

    context 'with multiple orders for the same compound' do
      before do
        stub_orders(order_for('H2O'), order_for('H2O'))
        stub_capabilities(full_capabilities.merge(teu_present: false))
      end

      it 'deduplicates demanded compounds' do
        result = optimizer.optimize_isru_priorities(settlement)
        expect(result[:demanded]).to eq(['H2O'])
      end
    end
  end

  # ── DEPLOYMENT_CHAIN constant ─────────────────────────────────────────────

  describe 'DEPLOYMENT_CHAIN' do
    it 'is frozen' do
      expect(described_class::DEPLOYMENT_CHAIN).to be_frozen
    end

    it 'phases are in ascending order' do
      numbers = described_class::DEPLOYMENT_CHAIN.map { |p| p[:phase] }
      expect(numbers).to eq(numbers.sort)
    end

    it 'all phases have name, phase, description, and needed_if' do
      described_class::DEPLOYMENT_CHAIN.each do |entry|
        expect(entry[:phase]).to be_a(Integer)
        expect(entry[:name]).to be_a(Symbol)
        expect(entry[:description]).to be_present
        expect(entry[:needed_if]).to respond_to(:call)
      end
    end

    it 'covers phases 2 through 5' do
      expect(described_class::DEPLOYMENT_CHAIN.map { |p| p[:phase] }).to eq([2, 3, 4, 5])
    end
  end
end
