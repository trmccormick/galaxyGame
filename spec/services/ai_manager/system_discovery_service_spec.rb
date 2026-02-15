require 'rails_helper'

RSpec.describe AIManager::SystemDiscoveryService do
  let(:shared_context) { {} }
  let(:service) { described_class.new(shared_context) }

  describe '#discover_available_systems' do
    it 'returns an array of system analyses' do
      systems = service.discover_available_systems
      
      expect(systems).to be_an(Array)
      expect(systems).not_to be_empty
      
      if systems.any?
        system = systems.first
        expect(system).to include(:system_id, :identifier, :name, :tei_score, :strategic_value)
        expect(system[:tei_score]).to be_a(Numeric)
        expect(system[:strategic_value]).to be_a(Numeric)
      end
    end
  end

  describe '#calculate_tei' do
    let(:system) { SolarSystem.first || create(:solar_system) }
    
    it 'returns a numeric TEI score' do
      score = service.send(:calculate_tei, system)
      
      expect(score).to be_a(Numeric)
      expect(score).to be >= 0
      expect(score).to be <= 100
    end
  end

  describe '#analyze_system' do
    let(:system) { SolarSystem.first || create(:solar_system) }
    
    it 'returns a complete system analysis hash' do
      analysis = service.send(:analyze_system, system)
      
      expect(analysis).to include(
        :system_id, :identifier, :name, :tei_score, 
        :resource_profile, :wormhole_data, :strategic_value,
        :celestial_body_count, :star_data
      )
    end
  end
end
