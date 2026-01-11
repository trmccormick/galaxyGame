# spec/services/autonomous_mission_service_spec.rb
require 'rails_helper'

RSpec.describe AutonomousMissionService, type: :service do
  describe '.find_or_create_worldhouse_feature' do
    let(:celestial_body) { create(:celestial_body) }
    let(:location) { create(:celestial_location, celestial_body: celestial_body) }

    context 'when a lava tube exists' do
      let!(:lava_tube) { create(:lava_tube_feature, celestial_body: celestial_body, status: 'natural') }

      it 'returns the existing lava tube' do
        result = described_class.find_or_create_worldhouse_feature(location)
        expect(result).to eq(lava_tube)
      end
    end

    context 'when no lava tube exists but a valley exists' do
      let!(:valley) { create(:valley_feature, celestial_body: celestial_body, status: 'natural') }

      it 'returns the existing valley' do
        result = described_class.find_or_create_worldhouse_feature(location)
        expect(result).to eq(valley)
      end
    end

    context 'when no lava tube or valley exists but a canyon exists' do
      let!(:canyon) { create(:canyon_feature, celestial_body: celestial_body, status: 'natural') }

      it 'returns the existing canyon' do
        result = described_class.find_or_create_worldhouse_feature(location)
        expect(result).to eq(canyon)
      end
    end

    context 'when no suitable features exist' do
      it 'creates a new lava tube feature' do
        expect {
          @result = described_class.find_or_create_worldhouse_feature(location)
        }.to change(CelestialBodies::Features::LavaTube, :count).by(1)

        expect(@result).to be_a(CelestialBodies::Features::LavaTube)
        expect(@result.celestial_body).to eq(celestial_body)
        expect(@result.status).to eq('natural')
        expect(@result.feature_type).to eq('lava_tube')
      end
    end

    context 'priority order' do
      let!(:canyon) { create(:canyon_feature, celestial_body: celestial_body, status: 'natural') }
      let!(:valley) { create(:valley_feature, celestial_body: celestial_body, status: 'natural') }
      let!(:lava_tube) { create(:lava_tube_feature, celestial_body: celestial_body, status: 'natural') }

      it 'prioritizes lava tube over valley and canyon' do
        result = described_class.find_or_create_worldhouse_feature(location)
        expect(result).to eq(lava_tube)
      end
    end

    context 'when valley exists but no lava tube' do
      let!(:valley) { create(:valley_feature, celestial_body: celestial_body, status: 'natural') }

      it 'prioritizes valley over canyon' do
        canyon = create(:canyon_feature, celestial_body: celestial_body, status: 'natural')
        result = described_class.find_or_create_worldhouse_feature(location)
        expect(result).to eq(valley)
      end
    end
  end

  describe '.execute_base_building_sequence' do
    let(:manifest) { { 'mission_type' => 'base_building', 'robots' => [] } }
    let(:settlement) { create(:settlement) }
    let(:starship) { create(:base_craft) }

    before do
      # Mock the dependent methods to avoid complex setup
      allow(described_class).to receive(:find_or_create_worldhouse_feature).and_return(create(:lava_tube_feature))
      allow(described_class).to receive(:create_worldhouse_on_feature)
      allow(described_class).to receive(:transfer_initial_resources)
      allow(described_class).to receive(:queue_worldhouse_construction_jobs)
      allow(described_class).to receive(:deploy_robotic_workforce)
    end

    it 'calls the feature finding method' do
      described_class.execute_base_building_sequence(manifest, settlement, starship)

      expect(described_class).to have_received(:find_or_create_worldhouse_feature).with(settlement.location)
    end

    it 'logs mission progress' do
      expect(Rails.logger).to receive(:info).with("Base building sequence initiated for settlement: #{settlement.name}")

      described_class.execute_base_building_sequence(manifest, settlement, starship)
    end
  end
end