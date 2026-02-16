require 'rails_helper'
require_relative '../../../app/services/ai_manager/ai_priority_system'

RSpec.describe AIManager::AiPrioritySystem do
  let(:priority_system) { described_class.new }
  let(:settlement) { double('Settlement') }

  describe '#check_critical' do
    context 'when life support is critical' do
      before do
        allow(priority_system).to receive(:life_support_critical?).and_return(true)
        allow(priority_system).to receive(:atmospheric_critical?).and_return(false)
        allow(priority_system).to receive(:debt_critical?).and_return(false)
        allow(priority_system).to receive(:critical_resources).and_return([:oxygen])
      end

      it 'returns life support issue with highest priority' do
        issues = priority_system.check_critical(settlement)
        expect(issues.first[:type]).to eq(:life_support)
        expect(issues.first[:priority]).to eq(1000)
      end
    end

    context 'when atmospheric maintenance is critical' do
      before do
        allow(priority_system).to receive(:life_support_critical?).and_return(false)
        allow(priority_system).to receive(:atmospheric_critical?).and_return(true)
        allow(priority_system).to receive(:debt_critical?).and_return(false)
      end

      it 'returns atmospheric issue with high priority' do
        issues = priority_system.check_critical(settlement)
        expect(issues.first[:type]).to eq(:atmospheric_maintenance)
        expect(issues.first[:priority]).to eq(900)
      end
    end

    context 'when debt is critical' do
      before do
        allow(priority_system).to receive(:life_support_critical?).and_return(false)
        allow(priority_system).to receive(:atmospheric_critical?).and_return(false)
        allow(priority_system).to receive(:debt_critical?).and_return(true)
        allow(priority_system).to receive(:outstanding_debt).and_return(60000)
      end

      it 'returns debt issue with medium-high priority' do
        issues = priority_system.check_critical(settlement)
        expect(issues.first[:type]).to eq(:debt_repayment)
        expect(issues.first[:priority]).to eq(800)
      end
    end

    it 'sorts issues by priority descending' do
      allow(priority_system).to receive(:life_support_critical?).and_return(true)
      allow(priority_system).to receive(:atmospheric_critical?).and_return(true)
      allow(priority_system).to receive(:debt_critical?).and_return(true)
      allow(priority_system).to receive(:critical_resources).and_return([:oxygen])

      issues = priority_system.check_critical(settlement)
      expect(issues.map { |i| i[:priority] }).to eq([1000, 900, 800])
    end
  end

  describe '#check_operational' do
    context 'when resource procurement is needed' do
      before do
        allow(priority_system).to receive(:resource_shortage).and_return({
          resource: :structural_carbon, amount: 1000
        })
        allow(priority_system).to receive(:construction_needs).and_return(nil)
      end

      it 'returns resource procurement need' do
        needs = priority_system.check_operational(settlement)
        expect(needs.first[:type]).to eq(:resource_procurement)
        expect(needs.first[:priority]).to eq(500)
      end
    end

    context 'when construction is needed' do
      before do
        allow(priority_system).to receive(:resource_shortage).and_return(nil)
        allow(priority_system).to receive(:construction_needs).and_return({
          facility: :atmospheric_processor, priority: :high
        })
      end

      it 'returns construction need' do
        needs = priority_system.check_operational(settlement)
        expect(needs.first[:type]).to eq(:construction)
        expect(needs.first[:priority]).to eq(300)
      end
    end
  end

  describe '#can_expand?' do
    context 'when settlement has critical issues' do
      before do
        allow(priority_system).to receive(:check_critical).and_return([
          { type: :life_support, priority: 1000 }
        ])
      end

      it 'returns false' do
        expect(priority_system.can_expand?(settlement)).to be false
      end
    end

    context 'when settlement has operational needs' do
      before do
        allow(priority_system).to receive(:check_critical).and_return([])
        allow(priority_system).to receive(:check_operational).and_return([
          { type: :resource_procurement, priority: 500 }
        ])
      end

      it 'returns false' do
        expect(priority_system.can_expand?(settlement)).to be false
      end
    end

    context 'when settlement is stable' do
      before do
        allow(priority_system).to receive(:check_critical).and_return([])
        allow(priority_system).to receive(:check_operational).and_return([])
        allow(priority_system).to receive(:settlement_stable?).and_return(true)
      end

      it 'returns true' do
        expect(priority_system.can_expand?(settlement)).to be true
      end
    end
  end

  describe 'priority constants' do
    it 'defines critical priorities' do
      expect(described_class::CRITICAL_PRIORITIES).to include(
        life_support: 1000,
        atmospheric_maintenance: 900,
        debt_repayment: 800
      )
    end

    it 'defines operational priorities' do
      expect(described_class::OPERATIONAL_PRIORITIES).to include(
        resource_procurement: 500,
        construction: 300,
        expansion: 100
      )
    end
  end

  describe 'dynamic priority multipliers' do
    describe '#critical_multiplier' do
      it 'defaults to 1.0' do
        expect(priority_system.critical_multiplier).to eq(1.0)
      end
    end

    describe '#operational_multiplier' do
      it 'defaults to 1.0' do
        expect(priority_system.operational_multiplier).to eq(1.0)
      end
    end

    describe '#set_critical_multiplier' do
      it 'sets the critical multiplier' do
        priority_system.set_critical_multiplier(2.5)
        expect(priority_system.critical_multiplier).to eq(2.5)
      end

      it 'accepts float values' do
        priority_system.set_critical_multiplier(0.5)
        expect(priority_system.critical_multiplier).to eq(0.5)
      end

      it 'accepts integer values and converts to float' do
        priority_system.set_critical_multiplier(3)
        expect(priority_system.critical_multiplier).to eq(3.0)
      end
    end

    describe '#set_operational_multiplier' do
      it 'sets the operational multiplier' do
        priority_system.set_operational_multiplier(1.8)
        expect(priority_system.operational_multiplier).to eq(1.8)
      end

      it 'accepts float values' do
        priority_system.set_operational_multiplier(0.3)
        expect(priority_system.operational_multiplier).to eq(0.3)
      end

      it 'accepts integer values and converts to float' do
        priority_system.set_operational_multiplier(2)
        expect(priority_system.operational_multiplier).to eq(2.0)
      end
    end

    describe '#effective_critical_priorities' do
      before do
        priority_system.set_critical_multiplier(2.0)
      end

      it 'returns priorities multiplied by critical multiplier' do
        effective = priority_system.effective_critical_priorities
        expect(effective[:life_support]).to eq(2000) # 1000 * 2.0
        expect(effective[:atmospheric_maintenance]).to eq(1800) # 900 * 2.0
        expect(effective[:debt_repayment]).to eq(1600) # 800 * 2.0
      end

      it 'handles fractional multipliers' do
        priority_system.set_critical_multiplier(0.5)
        effective = priority_system.effective_critical_priorities
        expect(effective[:life_support]).to eq(500) # 1000 * 0.5
        expect(effective[:atmospheric_maintenance]).to eq(450) # 900 * 0.5
        expect(effective[:debt_repayment]).to eq(400) # 800 * 0.5
      end
    end

    describe '#effective_operational_priorities' do
      before do
        priority_system.set_operational_multiplier(1.5)
      end

      it 'returns priorities multiplied by operational multiplier' do
        effective = priority_system.effective_operational_priorities
        expect(effective[:resource_procurement]).to eq(750) # 500 * 1.5
        expect(effective[:construction]).to eq(450) # 300 * 1.5
        expect(effective[:expansion]).to eq(150) # 100 * 1.5
      end

      it 'handles fractional multipliers' do
        priority_system.set_operational_multiplier(0.8)
        effective = priority_system.effective_operational_priorities
        expect(effective[:resource_procurement]).to eq(400) # 500 * 0.8
        expect(effective[:construction]).to eq(240) # 300 * 0.8
        expect(effective[:expansion]).to eq(80) # 100 * 0.8
      end
    end

    describe 'integration with priority checking' do
      context 'when critical multiplier is applied' do
        before do
          priority_system.set_critical_multiplier(3.0)
          allow(priority_system).to receive(:life_support_critical?).and_return(true)
          allow(priority_system).to receive(:atmospheric_critical?).and_return(false)
          allow(priority_system).to receive(:debt_critical?).and_return(false)
          allow(priority_system).to receive(:critical_resources).and_return([:oxygen])
        end

        it 'uses effective critical priorities in check_critical' do
          issues = priority_system.check_critical(settlement)
          expect(issues.first[:priority]).to eq(3000) # 1000 * 3.0
        end
      end

      context 'when operational multiplier is applied' do
        it 'uses effective operational priorities in check_operational' do
          priority_system.set_operational_multiplier(2.5)
          allow(priority_system).to receive(:resource_shortage).and_return({ resource: :minerals, amount: 100 })
          allow(priority_system).to receive(:construction_needs).and_return(nil)

          issues = priority_system.check_operational(settlement)
          resource_issue = issues.find { |issue| issue[:type] == :resource_procurement }
          expect(resource_issue[:priority]).to eq(1250) # 500 * 2.5
        end
      end
    end

    describe 'multiplier validation' do
      it 'allows multipliers between 0.1 and 5.0' do
        expect { priority_system.set_critical_multiplier(0.1) }.not_to raise_error
        expect { priority_system.set_critical_multiplier(5.0) }.not_to raise_error
        expect { priority_system.set_operational_multiplier(0.1) }.not_to raise_error
        expect { priority_system.set_operational_multiplier(5.0) }.not_to raise_error
      end

      it 'clamps multipliers to 0.1-5.0 range' do
        priority_system.set_critical_multiplier(0.0)
        expect(priority_system.critical_multiplier).to eq(0.1)

        priority_system.set_critical_multiplier(10.0)
        expect(priority_system.critical_multiplier).to eq(5.0)

        priority_system.set_operational_multiplier(0.0)
        expect(priority_system.operational_multiplier).to eq(0.1)

        priority_system.set_operational_multiplier(10.0)
        expect(priority_system.operational_multiplier).to eq(5.0)
      end
    end
  end
end