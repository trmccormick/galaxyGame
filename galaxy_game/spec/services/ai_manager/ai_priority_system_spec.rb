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
end