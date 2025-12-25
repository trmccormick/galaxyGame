# spec/services/construction/segment_covering_service_spec.rb
require 'rails_helper'

RSpec.describe Manufacturing::Construction::SegmentCoveringService, type: :service do
  let(:settlement) { create(:settlement) }
  let(:worldhouse) { create(:worldhouse, settlement: settlement) }
  let(:blueprint) { create(:blueprint, name: 'Generic Panel Array') }
  let(:segment) do
    create(:worldhouse_segment,
      worldhouse: worldhouse,
      width_m: 100_000,  # 100km
      length_m: 50_000,  # 50km
      status: 'planned'
    )
  end
  
  describe '#initialize' do
    it 'uses modular_structural_panel as default' do
      service = described_class.new(segment)
      expect(service.panel_type).to eq('modular_structural_panel')
    end
    
    it 'finds settlement from worldhouse' do
      service = described_class.new(segment)
      expect(service.settlement).to eq(settlement)
    end
  end
  
  describe '#calculate_panel_specific_materials' do
    let(:service) { described_class.new(segment, 'modular_structural_panel', settlement) }
    
    it 'calculates worldhouse-scale materials' do
      materials = service.send(:calculate_panel_specific_materials, 'modular_structural_panel')
      
      expect(materials).to have_key('transparent_aluminum')
      expect(materials).to have_key('structural_steel')
      expect(materials).to have_key('support_cables')
    end
    
    it 'includes cable calculations for massive segments' do
      materials = service.send(:calculate_panel_specific_materials, 'modular_structural_panel')
      
      # Perimeter = 2 * (100_000 + 50_000) = 300_000m
      # Cables = 300_000 * 100 = 30_000_000 kg
      expect(materials['support_cables']).to eq(30_000_000)
    end
    
    it 'scales materials by panel count' do
      # 100km x 50km = 5,000,000,000 m²
      # Panels = 5,000,000,000 / 25 = 200,000,000 panels
      # With 5% wastage = 210,000,000 panels
      panel_count = ((segment.width_m / 5.0).ceil * (segment.length_m / 5.0).ceil * 1.05).ceil
      
      materials = service.send(:calculate_panel_specific_materials, 'modular_structural_panel')
      
      expect(materials['transparent_aluminum']).to eq((panel_count * 50).round)
    end
  end
  
  describe '#complexity_factor' do
    it 'returns 1.5 base factor for worldhouse' do
      service = described_class.new(segment, 'modular_structural_panel', settlement)
      expect(service.send(:complexity_factor)).to be_within(0.001).of(1.8) # 1.5 * 1.2 for large segment
    end
    
    it 'increases factor for very large segments' do
      allow(segment).to receive(:area_km2).and_return(5000) # Over 1000 km²
      
      service = described_class.new(segment, 'modular_structural_panel', settlement)
      expect(service.send(:complexity_factor)).to eq(1.5 * 1.2)
    end
  end
  
  describe '#calculate_equipment_requirements' do
    let(:service) { described_class.new(segment, 'modular_structural_panel', settlement) }
    
    it 'requires minimum 10 printers for worldhouse' do
      requirements = service.send(:calculate_equipment_requirements)
      printer_req = requirements.find { |r| r[:equipment_type] == '3d_printer' }
      
      expect(printer_req[:quantity]).to be >= 10
    end
    
    it 'requires heavy equipment' do
      requirements = service.send(:calculate_equipment_requirements)
      
      expect(requirements).to include(hash_including(equipment_type: 'heavy_lifter'))
      expect(requirements).to include(hash_including(equipment_type: 'construction_drone'))
    end
    
    it 'scales equipment for massive segments' do
      requirements = service.send(:calculate_equipment_requirements)
      
      drone_req = requirements.find { |r| r[:equipment_type] == 'construction_drone' }
      expect(drone_req[:quantity]).to eq(20) # More than skylight's 4
    end
  end
  
  describe '#schedule_construction' do
    let(:service) { described_class.new(segment, 'modular_structural_panel', settlement) }
    let(:construction_job) { create(:construction_job, jobable: segment) }
    let(:player) { create(:player) }
    let!(:correct_blueprint) { Blueprint.create!(name: 'modular_structural_panel', player: player) }
    before do
      segment.status = 'planned'
      segment.save! if segment.respond_to?(:save!)
      allow(segment).to receive(:covered?).and_return(false)
      allow(segment).to receive(:area_km2).and_return(5000)
      allow(segment).to receive(:save!).and_return(true)
      allow(Blueprint).to receive(:find_by).and_return(correct_blueprint)
      allow(correct_blueprint).to receive(:materials).and_return({ 'regolith_composite' => 100 })
    end
    
    it 'creates construction phases for large segments' do
      allow(Manufacturing::MaterialRequest).to receive(:create_material_requests_from_hash).and_return([])
      allow(Manufacturing::EquipmentRequest).to receive(:create_equipment_requests).and_return([])
      allow(segment).to receive(:area_km2).and_return(5000)
      
      result = service.schedule_construction
      job = result[:construction_job]
      
      expect(job.target_values).to have_key('construction_phases')
      phases = job.target_values['construction_phases']
      expect(phases.length).to eq(6) # Framework + 4 panel quarters + sealing
    end
    
    it 'includes phase names and durations' do
      allow(Manufacturing::MaterialRequest).to receive(:create_material_requests_from_hash).and_return([])
      allow(Manufacturing::EquipmentRequest).to receive(:create_equipment_requests).and_return([])
      allow(segment).to receive(:area_km2).and_return(5000)
      
      result = service.schedule_construction
      phases = result[:construction_job].target_values['construction_phases']
      
      expect(phases[0]).to include('name' => 'Framework Installation', 'duration_percent' => 30)
      expect(phases[1]).to include('name' => 'Panel Installation - Quarter 1')
    end
  end
end