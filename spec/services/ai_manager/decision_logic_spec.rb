# RSpec for ExpansionDecisionService and HammerProtocol
require 'rails_helper'

RSpec.describe 'AI Expansion Decision Logic', type: :service do
  let(:wormhole_manager) { double('WormholeManager', execute_shift_discharge: true) }

  let(:prize_system) do
    { system_id: 'terra-001', terraformable: true, resource_score: 0.8, risk_score: 0.1, instability_threshold: 100, current_mass: 50 }
  end
  let(:siphon_system) do
    { system_id: 'siphon-001', terraformable: false, resource_score: 0.2, risk_score: 0.9, instability_threshold: 100, current_mass: 50 }
  end
  let(:legendary_system) do
    { system_id: 'djew-716790', permanent_pair: true, em_bloom_rate: 0, stability_decay: 0, instability_threshold: 100, current_mass: 50 }
  end

  describe AIManager::ExpansionDecisionService do
    it 'assigns natural anchor to Prize system' do
      systems = [prize_system.dup]
      described_class.new(systems).evaluate_systems
      expect(systems.first[:expansion_strategy]).to eq(:natural_anchor)
    end

    it 'assigns hammer_protocol to Siphon system' do
      systems = [siphon_system.dup]
      described_class.new(systems).evaluate_systems
      expect(systems.first[:expansion_strategy]).to eq(:hammer_protocol)
    end

    it 'assigns legendary to Legendary anomaly and generates unique lore log' do
      systems = [legendary_system.dup]
      described_class.new(systems).evaluate_systems
      expect(systems.first[:expansion_strategy]).to eq(:legendary)
      expect(systems.first[:lore_log]).to match(/The sensors are flat/)
    end
  end

  describe AIManager::HammerProtocol do
    it 'executes hammer on Siphon system' do
      system = siphon_system.dup
      protocol = described_class.new(system, wormhole_manager)
      expect(protocol.execute).to be true
      expect(system[:current_mass]).to be > system[:instability_threshold]
    end

    it 'does not hammer Legendary anomaly' do
      system = legendary_system.dup
      protocol = described_class.new(system, wormhole_manager)
      expect(protocol.execute).to be false
      expect(system[:current_mass]).to eq(50)
    end
  end
end
