require 'rails_helper'
require_relative '../../../app/services/ai_manager'


RSpec.describe AIManager::OperationalManager do
  let(:settlement) { double('Settlement', id: 1, celestial_body: double('CelestialBody', data: {})) }
  let(:operational_manager) { described_class.new(settlement) }

  describe '#initialize' do
    it 'loads trained patterns' do
      expect(operational_manager.patterns).to be_a(Hash)
    end

    it 'initializes priority system' do
      expect(operational_manager.priorities).to be_an(AIManager::AiPrioritySystem)
    end
  end

  describe '#make_decision' do
    context 'when critical issues exist' do
      before do
        allow(operational_manager).to receive(:check_critical_priorities).and_return([
          { type: :life_support, severity: :critical, resources: [:oxygen] }
        ])
      end

      it 'handles critical issues' do
        decision = operational_manager.make_decision
        expect(decision[:action]).to eq(:emergency_procurement)
        expect(decision[:resource]).to eq(:oxygen)
      end
    end

    context 'when no critical issues but operational needs exist' do
      before do
        allow(operational_manager).to receive(:check_critical_priorities).and_return([])
        allow(operational_manager).to receive(:assess_operational_state).and_return([
          { type: :resource_procurement, resource: :water, amount: 1000 }
        ])
      end

      it 'handles operational needs' do
        decision = operational_manager.make_decision
        expect(decision[:action]).to eq(:resource_procurement)
        expect(decision[:resource]).to eq(:water)
      end
    end

    context 'when stable and expansion is feasible' do
      before do
        allow(operational_manager).to receive(:check_critical_priorities).and_return([])
        allow(operational_manager).to receive(:assess_operational_state).and_return([])
        allow(operational_manager).to receive(:settlement_stable?).and_return(true)
        allow(operational_manager).to receive(:consider_expansion).and_return({
          action: :expansion, pattern: :venus_pattern, reason: :pattern_match
        })
      end

      it 'considers expansion' do
        decision = operational_manager.make_decision
        expect(decision[:action]).to eq(:expansion)
        expect(decision[:pattern]).to eq(:venus_pattern)
      end
    end

    context 'when stable with no expansion opportunities' do
      before do
        allow(operational_manager).to receive(:check_critical_priorities).and_return([])
        allow(operational_manager).to receive(:assess_operational_state).and_return([])
        allow(operational_manager).to receive(:settlement_stable?).and_return(true)
        allow(operational_manager).to receive(:consider_expansion).and_return({
          action: :maintain, reason: :no_suitable_expansion
        })
      end

      it 'maintains current operations' do
        decision = operational_manager.make_decision
        expect(decision[:action]).to eq(:maintain)
      end
    end
  end

  describe '#execute_decision' do
    context 'emergency procurement decision' do
      let(:decision) { { action: :emergency_procurement, resource: :oxygen } }

      it 'calls emergency mission service' do
        expect(AIManager::EmergencyMissionService).to receive(:create_emergency_mission).with(settlement, :oxygen)
        operational_manager.execute_decision(decision)
      end
    end

    context 'resource procurement decision' do
      let(:decision) { { action: :resource_procurement, resource: :water, amount: 1000 } }

      it 'calls procurement service' do
        expect(AIManager::ProcurementService).to receive(:procure_resource).with(settlement, :water, 1000)
        operational_manager.execute_decision(decision)
      end
    end

    context 'construction decision' do
      let(:decision) { { action: :construction, facility: :atmospheric_processor } }

      it 'calls construction service' do
        expect(AIManager::ConstructionService).to receive(:build_facility).with(settlement, :atmospheric_processor)
        operational_manager.execute_decision(decision)
      end
    end

    context 'expansion decision' do
      let(:decision) { { action: :expansion, pattern: :venus_pattern } }

      it 'calls expansion service' do
        mock_pattern = { pattern_id: :venus_pattern }
        allow(operational_manager.patterns).to receive(:[]).with(:venus_pattern).and_return(mock_pattern)
        expect(AIManager::ExpansionService).to receive(:expand_with_pattern).with(settlement, mock_pattern)
        operational_manager.execute_decision(decision)
      end
    end

    context 'debt repayment decision' do
      let(:decision) { { action: :debt_repayment, amount: 50000 } }

      it 'calls financial service' do
        expect(AIManager::FinancialService).to receive(:repay_debt).with(settlement, 50000)
        operational_manager.execute_decision(decision)
      end
    end
  end

  describe 'pattern matching' do
    let(:mock_patterns) do
      {
        npc_base_deploy_pattern: {
          pattern_id: :npc_base_deploy_pattern,
          economic_model: { estimated_gcc_cost: 450000, local_production_ratio: 1.0 },
          equipment_requirements: { total_unit_count: 45 }
        },
        venus_pattern: {
          pattern_id: :venus_pattern,
          economic_model: { estimated_gcc_cost: 500000, local_production_ratio: 0.0 },
          equipment_requirements: { total_unit_count: 0 }
        }
      }
    end

    before do
      allow(operational_manager).to receive(:load_trained_patterns).and_return(mock_patterns)
      operational_manager.instance_variable_set(:@patterns, mock_patterns)
    end

    describe '#find_expansion_pattern' do
      it 'returns the highest-scoring suitable pattern' do
        pattern = operational_manager.send(:find_expansion_pattern)
        expect(pattern).to eq([:npc_base_deploy_pattern, mock_patterns[:npc_base_deploy_pattern]])
      end

      it 'scores patterns based on ISRU ratio and equipment count' do
        # npc_base_deploy should score higher (50 ISRU + 45 equipment = 95)
        # venus_pattern should score lower (0 ISRU + 0 equipment = 0)
        result = operational_manager.send(:find_expansion_pattern)
        expect(result.first).to eq(:npc_base_deploy_pattern)
      end
    end

    describe '#pattern_suitable_for_expansion?' do
      it 'accepts patterns with cost and equipment' do
        suitable = operational_manager.send(:pattern_suitable_for_expansion?, mock_patterns[:npc_base_deploy_pattern])
        expect(suitable).to be true
      end

      it 'rejects patterns without equipment' do
        suitable = operational_manager.send(:pattern_suitable_for_expansion?, mock_patterns[:venus_pattern])
        expect(suitable).to be false
      end
    end
  end

  describe 'decision logging' do
    it 'logs decisions with timestamps and categories' do
      allow(operational_manager).to receive(:check_critical_priorities).and_return([])
      allow(operational_manager).to receive(:assess_operational_state).and_return([])
      allow(operational_manager).to receive(:settlement_stable?).and_return(true)
      allow(operational_manager).to receive(:consider_expansion).and_return({ action: :maintain, reason: :stable })

      operational_manager.make_decision

      expect(operational_manager.last_decision[:decision][:action]).to eq(:maintain)
      expect(operational_manager.instance_variable_get(:@decision_log)).to_not be_empty
    end
  end

  describe '#determine_dc_type' do
    let(:world_analysis) { { world_name: world_name, world_type: :terrestrial_planet } }
    let(:world_name) { nil }

    context 'with Ceres' do
      let(:world_name) { 'Ceres' }

      it 'forms Ceres Development Corporation aligned with Mars' do
        result = operational_manager.send(:determine_dc_type, world_analysis)
        expect(result[:dc_type]).to eq(:ceres_development_corporation)
        expect(result[:alignment]).to eq(:mars_development_corporation)
        expect(result[:region]).to eq(:asteroid_belt)
      end
    end

    context 'with Mars' do
      let(:world_name) { 'Mars' }

      it 'forms independent Mars Development Corporation' do
        result = operational_manager.send(:determine_dc_type, world_analysis)
        expect(result[:dc_type]).to eq(:mars_development_corporation)
        expect(result[:alignment]).to eq(:independent)
        expect(result[:region]).to eq(:inner_solar)
      end
    end

    context 'with Titan' do
      let(:world_name) { 'Titan' }

      it 'forms Titan Development Corporation aligned with Saturn' do
        result = operational_manager.send(:determine_dc_type, world_analysis)
        expect(result[:dc_type]).to eq(:titan_development_corporation)
        expect(result[:alignment]).to eq(:saturn_development_corporation)
        expect(result[:region]).to eq(:saturn_system)
      end
    end

    context 'with unknown world' do
      let(:world_name) { 'Unknown' }

      it 'falls back to world type classification' do
        result = operational_manager.send(:determine_dc_type, world_analysis)
        expect(result[:dc_type]).to eq(:mars_development_corporation)
        expect(result[:alignment]).to eq(:regional_coordination)
        expect(result[:region]).to eq(:inner_solar)
      end
    end
  end
end