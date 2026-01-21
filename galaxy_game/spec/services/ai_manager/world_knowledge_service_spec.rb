require 'rails_helper'
require_relative '../../../app/services/ai_manager'

RSpec.describe AIManager::WorldKnowledgeService, type: :service do
  let(:service) { described_class.new }

  describe '#generate_system_easter_egg' do
    context 'when has_wormhole is true' do
      it 'returns easter egg data for wormhole systems' do
        result = service.generate_system_easter_egg(true)
        expect(result).to be_a(Hash)
        expect(result.keys).to include(:flavor_text, :easter_egg_id, :manifest_entry)
      end
    end

    context 'when has_wormhole is false' do
      it 'returns nil' do
        result = service.generate_system_easter_egg(false)
        expect(result).to be_nil
      end
    end
  end

  describe '#find_matching_easter_egg' do
    let(:easter_eggs) do
      [
        {
          'easter_egg_id' => 'test_egg',
          'category' => 'world_naming',
          'flavor_text' => 'Test flavor',
          'trigger_conditions' => { 'has_wormhole' => true, 'rarity' => 1.0 }
        }
      ]
    end

    it 'matches easter eggs with has_wormhole trigger' do
      result = service.send(:find_matching_easter_egg, easter_eggs, nil, 0, 0, false, false, true)
      expect(result['easter_egg_id']).to eq('test_egg')
    end

    it 'does not match when has_wormhole is false' do
      result = service.send(:find_matching_easter_egg, easter_eggs, nil, 0, 0, false, false, false)
      expect(result).to be_nil
    end
  end
end