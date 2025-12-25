# spec/services/construction/skylight_service_spec.rb
require 'rails_helper'

RSpec.describe Manufacturing::Construction::SkylightService, type: :service do
  let(:settlement) { create(:settlement) }
  let(:lava_tube) { create(:lava_tube, settlement: settlement) }
  let(:skylight) do
    create(:skylight,
      diameter: 50,
      position: 100,
      status: 'uncovered',
      lava_tube: lava_tube
    )
  end
  let(:blueprint) { create(:blueprint, name: 'basic_transparent_crater_tube_cover_array') }
  
  describe '#initialize' do
    it 'uses skylight-specific default panel type' do
      service = described_class.new(skylight)
      expect(service.panel_type).to eq('basic_transparent_crater_tube_cover_array')
    end
    
    it 'finds settlement from lava tube' do
      service = described_class.new(skylight)
      expect(service.settlement).to eq(settlement)
    end
  end
  
  describe '#calculate_panel_specific_materials' do
    let(:service) { described_class.new(skylight, 'transparent_cover_panel', settlement) }
    
    it 'calculates transparent panel materials' do
      materials = service.send(:calculate_panel_specific_materials, 'transparent_cover_panel')
      
      expect(materials).to have_key('silicate_glass')
      expect(materials).to have_key('aluminum_frame')
      expect(materials).to have_key('ceramic_composite')
    end
    
    it 'calculates solar panel materials' do
      materials = service.send(:calculate_panel_specific_materials, 'solar_cover_panel')
      
      expect(materials).to have_key('advanced_solar_cells')
      expect(materials).to have_key('graphene_layers')
    end
    
    it 'scales materials by panel count' do
      allow(Manufacturing::Construction::CoveringCalculator).to receive(:calculate_panel_count)
        .and_return(200)
      
      materials = service.send(:calculate_panel_specific_materials, 'transparent_cover_panel')
      
      expect(materials['silicate_glass']).to eq(200 * 25)
      expect(materials['aluminum_frame']).to eq(200 * 5)
    end
  end
  
  describe '#complexity_factor' do
    it 'returns 1.0 for basic transparent panels' do
      service = described_class.new(skylight, 'basic_transparent_crater_tube_cover_array', settlement)
      expect(service.send(:complexity_factor)).to eq(1.0)
    end
    
    it 'returns 1.5 for solar panels' do
      service = described_class.new(skylight, 'solar_cover_panel', settlement)
      expect(service.send(:complexity_factor)).to eq(1.5)
    end
    
    it 'returns 1.3 for thermal insulation' do
      service = described_class.new(skylight, 'thermal_insulation_cover_panel', settlement)
      expect(service.send(:complexity_factor)).to eq(1.3)
    end
  end
  
  describe '#determine_completion_status' do
    let(:service) { described_class.new(skylight, 'transparent_cover_panel', settlement) }
    
    it 'returns primary_cover for basic transparent' do
      status = service.send(:determine_completion_status, 'basic_transparent_crater_tube_cover_array')
      expect(status).to eq('primary_cover')
    end
    
    it 'returns solar_cover for solar panels' do
      status = service.send(:determine_completion_status, 'solar_cover_panel')
      expect(status).to eq('solar_cover')
    end
    
    it 'returns full_cover for structural on primary cover' do
      allow(skylight).to receive(:status).and_return('primary_cover')
      status = service.send(:determine_completion_status, 'structural_cover_panel')
      expect(status).to eq('full_cover')
    end
  end
end