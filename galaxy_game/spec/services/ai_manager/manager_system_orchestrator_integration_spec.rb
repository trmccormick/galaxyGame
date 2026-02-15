# spec/services/ai_manager/manager_system_orchestrator_integration_spec.rb
require 'rails_helper'
require 'ai_manager/manager'
require 'ai_manager/system_orchestrator'
require 'ai_manager/shared_context'

RSpec.describe AIManager::Manager, "System Orchestrator Integration" do
  let(:mars_settlement) { create(:base_settlement, name: "Mars Base") }
  let(:luna_settlement) { create(:base_settlement, name: "Luna Base") }
  let(:shared_context) { AIManager::SharedContext.new }
  let(:system_orchestrator) { AIManager::SystemOrchestrator.new(shared_context) }

  describe "with system orchestrator" do
    it "registers settlement with system orchestrator during initialization" do
      manager = AIManager::Manager.new(target_entity: mars_settlement, system_orchestrator: system_orchestrator)
      expect(system_orchestrator.settlements.size).to eq(1)
      expect(system_orchestrator.settlements.first.name).to eq("Mars Base")
    end

    it "provides access to system orchestrator" do
      manager = AIManager::Manager.new(target_entity: mars_settlement, system_orchestrator: system_orchestrator)
      expect(manager.system_orchestrator).to eq(system_orchestrator)
      expect(manager.system_orchestrator?).to be true
    end

    it "calls orchestrate_system during advance_time" do
      manager = AIManager::Manager.new(target_entity: mars_settlement, system_orchestrator: system_orchestrator)
      expect(system_orchestrator).to receive(:orchestrate_system).once

      manager.advance_time
    end
  end

  describe "without system orchestrator" do
    it "works without system orchestrator" do
      manager = AIManager::Manager.new(target_entity: mars_settlement)
      expect(manager.system_orchestrator?).to be false
      expect(manager.system_orchestrator).to be nil

      # Should not raise an error
      expect { manager.advance_time }.not_to raise_error
    end
  end
end