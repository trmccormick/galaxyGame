require 'rails_helper'

RSpec.describe AIManager::ColonyManager, type: :service do
  let(:mock_colony) do
    double('Colony', name: 'Ceres Alpha', auto_manage: true, resources: ['water'])
  end

  let(:manager) { described_class.new }

  before do
    allow(manager).to receive(:load_ceres_profile).and_return({ 'phase' => 1, 'roi' => 0.87 })
    manager.set_player_colony(mock_colony)
  end

  describe '#handle_player_trade' do
    it 'calculates the correct ROI for Ceres Phase 1 water export' do
      roi = manager.handle_player_trade
      expect(roi).to eq(0.87)
    end
  end
end
