require 'rails_helper'
require_relative '../../../app/services/ai_manager'


RSpec.describe AIManager::SystemArchitect do
  let(:celestial_body) { create(:celestial_body, name: 'Test Planet', has_magnetosphere: false) }
  let(:architect) { described_class.new(celestial_body) }

  describe '#initialize' do
    it 'analyzes system configuration' do
      expect(architect.celestial_body).to eq(celestial_body)
      expect(architect.system_config).to be_a(Hash)
    end
  end

  describe '#analyze_system_configuration' do
    context 'with moons' do
      let!(:large_moon) { create(:celestial_body, name: 'Large Moon', mass: 1e21, parent_celestial_body_id: celestial_body.id) }
      let!(:small_moon) { create(:celestial_body, name: 'Small Moon', mass: 1e19, parent_celestial_body_id: celestial_body.id) }

      it 'identifies large and small moons' do
        config = architect.send(:analyze_system_configuration)
        expect(config[:moon_count]).to eq(2)
        expect(config[:large_moons].size).to eq(1)
        expect(config[:small_moons].size).to eq(1)
      end
    end

    context 'without moons' do
      it 'identifies moonless system' do
        config = architect.send(:analyze_system_configuration)
        expect(config[:moonless]).to be true
        expect(config[:moon_count]).to eq(0)
      end
    end
  end

  describe '#determine_deployment_template' do
    context 'with 2+ small moons' do
      before do
        allow(architect).to receive(:system_config).and_return({
          small_moons: [double, double],
          large_moons: [],
          moonless: false
        })
      end

      it 'returns conversion template' do
        expect(architect.send(:determine_deployment_template)).to eq(:conversion)
      end
    end

    context 'with large moon' do
      before do
        allow(architect).to receive(:system_config).and_return({
          small_moons: [],
          large_moons: [double],
          moonless: false
        })
      end

      it 'returns lunar_standard template' do
        expect(architect.send(:determine_deployment_template)).to eq(:lunar_standard)
      end
    end

    context 'moonless with nearby asteroid' do
      before do
        allow(architect).to receive(:system_config).and_return({
          small_moons: [],
          large_moons: [],
          moonless: true
        })
        allow(architect).to receive(:find_nearby_asteroid).and_return(double)
      end

      it 'returns asteroid_capture template' do
        expect(architect.send(:determine_deployment_template)).to eq(:asteroid_capture)
      end
    end

    context 'moonless without asteroid' do
      before do
        allow(architect).to receive(:system_config).and_return({
          small_moons: [],
          large_moons: [],
          moonless: true
        })
        allow(architect).to receive(:find_nearby_asteroid).and_return(nil)
      end

      it 'returns cycler_staging template' do
        expect(architect.send(:determine_deployment_template)).to eq(:cycler_staging)
      end
    end
  end

  describe '#deploy_subsurface_foothold' do
    it 'creates subsurface location' do
      expect { architect.send(:deploy_subsurface_foothold) }.to change(CelestialLocation, :count).by(1)
    end

    it 'creates settlement' do
      expect { architect.send(:deploy_subsurface_foothold) }.to change(Settlement::BaseSettlement, :count).by(1)
    end

    # TODO: Implement structure creation methods
    # it 'creates habitat structures' do
    #   expect { architect.send(:deploy_subsurface_foothold) }.to change(Structures::BaseStructure, :count).by(4) # habitat, power, comms, life support
    # end
  end

  describe '#find_nearby_asteroid' do
    let(:solar_system) { create(:solar_system) }
    let(:celestial_body) { create(:celestial_body, solar_system: solar_system) }

    context 'with suitable asteroid' do
      let!(:asteroid) { create(:asteroid, solar_system: solar_system) }

      it 'finds the asteroid' do
        result = architect.send(:find_nearby_asteroid)
        expect(result).to eq(asteroid)
      end
    end

    context 'without suitable asteroid' do
      it 'returns nil' do
        result = architect.send(:find_nearby_asteroid)
        expect(result).to be_nil
      end
    end
  end

  describe '#transfer_ownership_to_system_corp' do
    it 'creates system specific corporation' do
      bootstrap_corp = create(:organization)
      allow(architect).to receive(:find_bootstrap_corporation).and_return(bootstrap_corp)
      expect { architect.send(:transfer_ownership_to_system_corp) }.to change(Organizations::BaseOrganization, :count).by(1)
    end

    it 'transfers settlements' do
      bootstrap_corp = architect.send(:find_bootstrap_corporation)
      settlement = create(:base_settlement, owner: bootstrap_corp)

      expect { architect.send(:transfer_ownership_to_system_corp) }.to change { settlement.reload.owner }
    end
  end
end