require 'rails_helper'

RSpec.describe AIManager::ExpansionDecisionService, type: :service do
  let(:service) { described_class.new }

  describe '#optimize_routes' do
    let(:systems) do
      [
        { anomaly_id: 'SYS-001', maintenance_cost: 120, transit_revenue: 100 },
        { anomaly_id: 'SYS-002', maintenance_cost: 80, transit_revenue: 90 },
        { anomaly_id: 'DJEW-716790', maintenance_cost: 999, transit_revenue: 0 }, # Legendary
        { anomaly_id: 'FR-488530', maintenance_cost: 999, transit_revenue: 0 },   # Legendary
      ]
    end

    it 'marks recall_decommission for deficit systems except Legendary Pair' do
      service.optimize_routes(systems)
      expect(systems[0][:recall_decommission]).to eq(true)
      expect(systems[1][:recall_decommission]).to eq(false)
      expect(systems[2][:recall_decommission]).to be_nil
      expect(systems[3][:recall_decommission]).to be_nil
    end
  end

  describe '#legendary_anomaly?' do
    it 'returns true for Legendary Pair' do
      expect(service.legendary_anomaly?(anomaly_id: 'DJEW-716790')).to eq(true)
      expect(service.legendary_anomaly?(anomaly_id: 'FR-488530')).to eq(true)
    end

    it 'returns false for non-Legendary' do
      expect(service.legendary_anomaly?(anomaly_id: 'SYS-001')).to eq(false)
    end
  end
end
