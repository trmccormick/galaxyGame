require 'rails_helper'

RSpec.describe Construction::OrbitalShipyardService, type: :service do
  let(:player) { create(:player) }
  let(:station) { create(:base_settlement, :station, owner: player) }

  describe '.create_shipyard_project' do
    let(:blueprint_id) { 'earth_mars_cycler' }

    context 'with valid parameters' do
      it 'creates a new orbital construction project' do
        expect {
          described_class.create_shipyard_project(station, blueprint_id)
        }.to change(OrbitalConstructionProject, :count).by(1)
      end

      it 'associates the project with the station' do
        project = described_class.create_shipyard_project(station, blueprint_id)
        expect(project.station).to eq(station)
      end

      it 'sets the correct blueprint_id' do
        project = described_class.create_shipyard_project(station, blueprint_id)
        expect(project.craft_blueprint_id).to eq(blueprint_id)
      end

      it 'sets initial status to materials_pending' do
        project = described_class.create_shipyard_project(station, blueprint_id)
        expect(project.status).to eq('materials_pending')
      end

      it 'initializes progress_percentage to 0' do
        project = described_class.create_shipyard_project(station, blueprint_id)
        expect(project.progress_percentage).to eq(0.0)
      end

      it 'loads required materials from blueprint' do
        project = described_class.create_shipyard_project(station, blueprint_id)
        expect(project.required_materials).to be_a(Hash)
        expect(project.required_materials.keys).to include('ibeam', 'aluminum_alloy')
      end

      it 'initializes delivered_materials with zero values' do
        project = described_class.create_shipyard_project(station, blueprint_id)
        expect(project.delivered_materials).to be_a(Hash)
        project.required_materials.each_key do |material|
          expect(project.delivered_materials[material]).to eq(0)
        end
      end
    end

    context 'with invalid blueprint_id' do
      it 'raises an error' do
        expect {
          described_class.create_shipyard_project(station, 'invalid_blueprint')
        }.to raise_error(RuntimeError, /Blueprint not found/)
      end
    end
  end

  describe '.deliver_materials' do
    let!(:project) { create(:orbital_construction_project, station: station) }
    let(:material_type) { 'ibeam' }
    let(:quantity) { 500 }

    before do
      project.update!(
        required_materials: { 'ibeam' => 1000, 'aluminum_alloy' => 500 },
        delivered_materials: { 'ibeam' => 0, 'aluminum_alloy' => 0 }
      )
    end

    context 'when material is needed' do
      it 'consumes the material for the project' do
        expect {
          described_class.deliver_materials(station, material_type, quantity)
        }.to change { project.reload.delivered_materials[material_type] }.from(0).to(500)
      end

      it 'returns the unconsumed quantity' do
        unconsumed = described_class.deliver_materials(station, material_type, quantity)
        expect(unconsumed).to eq(0)
      end

      it 'does not consume more than needed' do
        excess_quantity = 1500
        unconsumed = described_class.deliver_materials(station, material_type, excess_quantity)
        expect(unconsumed).to eq(500) # 1500 - 1000 needed
        expect(project.reload.delivered_materials[material_type]).to eq(1000)
      end
    end

    context 'when material is not needed' do
      let(:unneeded_material) { 'unknown_material' }

      it 'returns the full quantity' do
        unconsumed = described_class.deliver_materials(station, unneeded_material, quantity)
        expect(unconsumed).to eq(quantity)
      end

      it 'does not update any project materials' do
        original_delivered = project.delivered_materials.dup
        described_class.deliver_materials(station, unneeded_material, quantity)
        expect(project.reload.delivered_materials).to eq(original_delivered)
      end
    end

    context 'when project becomes ready' do
      before do
        project.update!(delivered_materials: { 'ibeam' => 500, 'aluminum_alloy' => 500 })
      end

      it 'changes status to in_progress when all materials are delivered' do
        described_class.deliver_materials(station, 'ibeam', 500)
        expect(project.reload.status).to eq('in_progress')
        expect(project.construction_started_at).to be_present
      end
    end

    context 'with multiple projects' do
      let!(:project2) { create(:orbital_construction_project, station: station) }

      before do
        project2.update!(
          required_materials: { 'ibeam' => 800 },
          delivered_materials: { 'ibeam' => 0 }
        )
      end

      it 'distributes materials across projects' do
        total_needed = 1000 + 800 # 1800
        delivered_quantity = 1200

        unconsumed = described_class.deliver_materials(station, material_type, delivered_quantity)

        project.reload
        project2.reload

        expect(project.delivered_materials[material_type]).to eq(1000)
        expect(project2.delivered_materials[material_type]).to eq(200)
        expect(unconsumed).to eq(0)
      end
    end
  end

  describe '.update_construction_progress' do
    let!(:project) { create(:orbital_construction_project, station: station, status: :in_progress) }

    it 'increases progress percentage' do
      initial_progress = project.progress_percentage
      described_class.update_construction_progress
      expect(project.reload.progress_percentage).to be > initial_progress
    end

    it 'does not exceed 100%' do
      project.update!(progress_percentage: 99.0)
      described_class.update_construction_progress
      expect(project.reload.progress_percentage).to eq(100.0)
    end

    context 'when progress reaches 100%' do
      before do
        project.update!(progress_percentage: 99.0)
        allow(described_class).to receive(:complete_project)
      end

      it 'completes the project' do
        described_class.update_construction_progress
        expect(described_class).to have_received(:complete_project).with(project)
      end
    end
  end

  describe '.complete_project' do
    let!(:project) { create(:orbital_construction_project, station: station, status: :in_progress) }

    it 'marks the project as completed' do
      described_class.complete_project(project)
      expect(project.reload.status).to eq('completed')
      expect(project.completed_at).to be_present
    end

    it 'spawns the completed craft' do
      expect(described_class).to receive(:spawn_completed_craft).with(project)
      described_class.complete_project(project)
    end
  end

  describe '.spawn_completed_craft' do
    let!(:project) { create(:orbital_construction_project, station: station, craft_blueprint_id: 'earth_mars_cycler') }

    it 'creates a new craft' do
      expect {
        described_class.spawn_completed_craft(project)
      }.to change(Craft::BaseCraft, :count).by(1)
    end

    it 'associates the craft with the station' do
      craft = described_class.spawn_completed_craft(project)
      expect(craft.docked_at).to eq(station)
    end

    it 'sets the craft status to docked' do
      craft = described_class.spawn_completed_craft(project)
      expect(craft.status).to eq('docked')
    end

    it 'loads operational data from blueprint' do
      craft = described_class.spawn_completed_craft(project)
      expect(craft.operational_data).to be_present
      expect(craft.operational_data['cycler_type']).to eq('earth_mars')
    end
  end

  describe '.load_craft_blueprint' do
    context 'with valid blueprint_id' do
      it 'loads the blueprint from JSON file' do
        blueprint = described_class.send(:load_craft_blueprint, 'earth_mars_cycler')
        expect(blueprint).to be_a(Hash)
        expect(blueprint['name']).to eq('Earth-Mars Cycler')
      end
    end

    context 'with invalid blueprint_id' do
      it 'raises an error' do
        expect {
          described_class.send(:load_craft_blueprint, 'invalid_blueprint')
        }.to raise_error(RuntimeError, /Blueprint not found/)
      end
    end
  end
end