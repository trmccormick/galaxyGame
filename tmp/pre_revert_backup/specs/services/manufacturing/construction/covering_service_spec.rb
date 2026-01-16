# spec/services/construction/covering_service_spec.rb
require 'rails_helper'

RSpec.describe Manufacturing::Construction::CoveringService, type: :service do
  let(:settlement) { create(:settlement) }
  let(:blueprint) { create(:blueprint, name: 'Generic Panel Array') }
  let(:coverable) { create(:crater_dome, settlement: settlement) }
  
  describe '#initialize' do
    it 'initializes with coverable, panel type, and settlement' do
      service = described_class.new(coverable, 'modular_structural_panel', settlement)
      
      expect(service.coverable).to eq(coverable)
      expect(service.panel_type).to eq('modular_structural_panel')
      expect(service.settlement).to eq(settlement)
    end
    
    it 'uses default panel type if not provided' do
      service = described_class.new(coverable, nil, settlement)
      expect(service.panel_type).to eq('modular_structural_panel')
    end
    
    it 'finds settlement from coverable if not provided' do
      service = described_class.new(coverable)
      expect(service.settlement).to eq(settlement)
    end
  end
  
  describe '#calculate_materials' do
    let(:service) { described_class.new(coverable, 'modular_structural_panel', settlement) }
    
    it 'calculates base materials using CoveringCalculator' do
      expect(Manufacturing::Construction::CoveringCalculator).to receive(:calculate_materials)
        .with(coverable, anything)
        .and_return({
          '3d_printed_ibeams' => 100,
          'transparent_panels' => 200,
          'sealant' => 50
        })
      
      materials = service.calculate_materials
      
      expect(materials).to have_key('3d_printed_ibeams')
      expect(materials).to have_key('transparent_panels')
      expect(materials).to have_key('sealant')
    end
    
    it 'merges panel-specific materials' do
      allow(Manufacturing::Construction::CoveringCalculator).to receive(:calculate_materials)
        .and_return({ 'base_material' => 100 })
      
      allow(service).to receive(:calculate_panel_specific_materials)
        .and_return({ 'special_material' => 50 })
      
      materials = service.calculate_materials
      
      expect(materials['base_material']).to eq(100)
      expect(materials['special_material']).to eq(50)
    end
    
    it 'sums quantities for duplicate materials' do
      allow(Manufacturing::Construction::CoveringCalculator).to receive(:calculate_materials)
        .and_return({ 'shared_material' => 100 })
      
      allow(service).to receive(:calculate_panel_specific_materials)
        .and_return({ 'shared_material' => 50 })
      
      materials = service.calculate_materials
      
      expect(materials['shared_material']).to eq(150)
    end
  end
  
  describe '#schedule_construction' do
    let(:service) { described_class.new(coverable, 'modular_structural_panel', settlement) }
    let!(:blueprint) { create(:blueprint, name: 'Generic Panel Array') }
    let(:construction_job) { create(:construction_job, jobable: coverable) }
    
    before do
      allow(Manufacturing::MaterialRequest).to receive(:create_material_requests_from_hash).and_return([])
      allow(Manufacturing::EquipmentRequest).to receive(:create_equipment_requests).and_return([])
    end
    
    it 'returns error if no settlement' do
      # Create a coverable without a settlement
      coverable_without_settlement = create(:crater_dome, name: 'Unique Test Dome', settlement: nil)
      service = described_class.new(coverable_without_settlement, 'modular_structural_panel', nil)
      result = service.schedule_construction
      
      expect(result[:success]).to be false
      expect(result[:message]).to include('No settlement')
    end
    
    it 'returns error if no blueprint found' do
      allow(service).to receive(:find_blueprint).and_return(nil)
      service.instance_variable_set(:@blueprint, nil)
      result = service.schedule_construction
      
      expect(result[:success]).to be false
      expect(result[:message]).to include('No blueprint found')
    end
    
    it 'creates a construction job' do
      expect {
        service.schedule_construction
      }.to change { ConstructionJob.count }.by(1)
    end
    
    it 'creates material requests' do
      expect(Manufacturing::MaterialRequest).to receive(:create_material_requests_from_hash)
      service.schedule_construction
    end
    
    it 'creates equipment requests' do
      expect(Manufacturing::EquipmentRequest).to receive(:create_equipment_requests)
      service.schedule_construction
    end
    
    it 'updates coverable status to materials_requested' do
      expect(coverable).to receive(:update).with(hash_including(cover_status: 'materials_requested'))
      service.schedule_construction
    end
    
    it 'returns success with construction job' do
      result = service.schedule_construction
      
      expect(result[:success]).to be true
      expect(result[:construction_job]).to be_a(ConstructionJob)
      expect(result[:message]).to include('scheduled')
    end
  end
  
  describe '#start_construction' do
    let(:service) { described_class.new(coverable, 'modular_structural_panel', settlement) }
    let(:construction_job) do
      create(:construction_job,
        jobable: coverable,
        status: 'materials_pending'
      )
    end
    
    it 'returns false if materials not gathered' do
      allow(construction_job).to receive(:materials_gathered?).and_return(false)
      expect(service.start_construction(construction_job)).to be false
    end
    
    it 'returns false if equipment not gathered' do
      allow(construction_job).to receive(:materials_gathered?).and_return(true)
      allow(construction_job).to receive(:equipment_gathered?).and_return(false)
      
      expect(service.start_construction(construction_job)).to be false
    end
    
    it 'updates job status to in_progress' do
      allow(construction_job).to receive(:materials_gathered?).and_return(true)
      allow(construction_job).to receive(:equipment_gathered?).and_return(true)
      allow(Manufacturing::Construction::ConstructionManager).to receive(:assign_builders)
      
      expect(construction_job).to receive(:update).with(status: 'in_progress')
      service.start_construction(construction_job)
    end
    
    it 'assigns builders through ConstructionManager' do
      allow(construction_job).to receive(:materials_gathered?).and_return(true)
      allow(construction_job).to receive(:equipment_gathered?).and_return(true)
      
      expect(Manufacturing::Construction::ConstructionManager).to receive(:assign_builders)
      service.start_construction(construction_job)
    end
    
    it 'updates coverable status to under_construction' do
      allow(construction_job).to receive(:materials_gathered?).and_return(true)
      allow(construction_job).to receive(:equipment_gathered?).and_return(true)
      allow(Manufacturing::Construction::ConstructionManager).to receive(:assign_builders)
      
      expect(coverable).to receive(:update).with(hash_including(cover_status: 'under_construction'))
      service.start_construction(construction_job)
    end
  end
  
  describe '#track_progress' do
    let(:service) { described_class.new(coverable, 'modular_structural_panel', settlement) }
    let(:construction_job) do
      create(:construction_job,
        jobable: coverable,
        status: 'in_progress',
        target_values: { 'panel_type' => 'modular_structural_panel' }
      )
    end
    
    it 'returns false if job not in progress' do
      construction_job.update(status: 'completed')
      expect(service.track_progress(construction_job)).to be false
    end
    
    it 'returns false if construction not complete' do
      allow(Manufacturing::Construction::ConstructionManager).to receive(:complete?).and_return(false)
      expect(service.track_progress(construction_job)).to be false
    end
    
    it 'completes construction when work is done' do
      allow(Manufacturing::Construction::ConstructionManager).to receive(:complete?).and_return(true)
      allow(Manufacturing::Construction::EquipmentManager).to receive(:release_equipment)
      
      expect(construction_job).to receive(:update).with(hash_including(status: 'completed'))
      service.track_progress(construction_job)
    end
    
    it 'updates coverable status' do
      allow(Manufacturing::Construction::ConstructionManager).to receive(:complete?).and_return(true)
      allow(Manufacturing::Construction::EquipmentManager).to receive(:release_equipment)
      
      expect(coverable).to receive(:update).with(hash_including(cover_status: 'covered'))
      service.track_progress(construction_job)
    end
    
    it 'releases equipment' do
      allow(Manufacturing::Construction::ConstructionManager).to receive(:complete?).and_return(true)
      
      expect(Manufacturing::Construction::EquipmentManager).to receive(:release_equipment).with(construction_job)
      service.track_progress(construction_job)
    end
    
    it 'returns true when complete' do
      allow(Manufacturing::Construction::ConstructionManager).to receive(:complete?).and_return(true)
      allow(Manufacturing::Construction::EquipmentManager).to receive(:release_equipment)
      
      expect(service.track_progress(construction_job)).to be true
    end
  end
end
