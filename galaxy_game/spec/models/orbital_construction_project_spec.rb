require 'rails_helper'

RSpec.describe OrbitalConstructionProject, type: :model do
  let(:player) { create(:player) }
  let(:station) { create(:base_settlement, :station, owner: player) }

  describe 'associations' do
    it { should belong_to(:station).class_name('Settlement::BaseSettlement') }
  end

  describe 'validations' do
    it { should validate_presence_of(:craft_blueprint_id) }
    it { should validate_numericality_of(:progress_percentage).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(materials_pending: 0, in_progress: 1, completed: 2, failed: 3, canceled: 4) }
  end

  describe '#materials_complete?' do
    let(:project) { create(:orbital_construction_project, station: station) }

    context 'when all required materials are delivered' do
      before do
        project.update!(
          required_materials: { 'ibeam' => 100, 'aluminum_alloy' => 50 },
          delivered_materials: { 'ibeam' => 100, 'aluminum_alloy' => 50 }
        )
      end

      it 'returns true' do
        expect(project.materials_complete?).to be true
      end
    end

    context 'when some materials are missing' do
      before do
        project.update!(
          required_materials: { 'ibeam' => 100, 'aluminum_alloy' => 50 },
          delivered_materials: { 'ibeam' => 50, 'aluminum_alloy' => 50 }
        )
      end

      it 'returns false' do
        expect(project.materials_complete?).to be false
      end
    end

    context 'when materials exceed requirements' do
      before do
        project.update!(
          required_materials: { 'ibeam' => 100 },
          delivered_materials: { 'ibeam' => 150 }
        )
      end

      it 'returns true' do
        expect(project.materials_complete?).to be true
      end
    end
  end

  describe '#completion_percentage' do
    let(:project) { create(:orbital_construction_project, station: station) }

    context 'when no materials are delivered' do
      before do
        project.update!(
          required_materials: { 'ibeam' => 100, 'aluminum_alloy' => 100 },
          delivered_materials: { 'ibeam' => 0, 'aluminum_alloy' => 0 }
        )
      end

      it 'returns 0' do
        expect(project.completion_percentage).to eq(0)
      end
    end

    context 'when half materials are delivered' do
      before do
        project.update!(
          required_materials: { 'ibeam' => 100, 'aluminum_alloy' => 100 },
          delivered_materials: { 'ibeam' => 50, 'aluminum_alloy' => 50 }
        )
      end

      it 'returns 50' do
        expect(project.completion_percentage).to eq(50)
      end
    end

    context 'when all materials are delivered' do
      before do
        project.update!(
          required_materials: { 'ibeam' => 100, 'aluminum_alloy' => 100 },
          delivered_materials: { 'ibeam' => 100, 'aluminum_alloy' => 100 }
        )
      end

      it 'returns 100' do
        expect(project.completion_percentage).to eq(100)
      end
    end
  end

  describe 'JSONB storage' do
    let(:project) { create(:orbital_construction_project, station: station) }

    it 'stores required_materials as JSONB' do
      materials = { 'ibeam' => 1000, 'aluminum_alloy' => 500 }
      project.update!(required_materials: materials)
      project.reload
      expect(project.required_materials).to eq(materials)
    end

    it 'stores delivered_materials as JSONB' do
      materials = { 'ibeam' => 500, 'aluminum_alloy' => 250 }
      project.update!(delivered_materials: materials)
      project.reload
      expect(project.delivered_materials).to eq(materials)
    end

    it 'stores project_metadata as JSONB' do
      metadata = { 'priority' => 'high', 'notes' => 'Urgent cycler needed' }
      project.update!(project_metadata: metadata)
      project.reload
      expect(project.project_metadata).to eq(metadata)
    end
  end
end