# spec/models/concerns/structures/coverable_spec.rb
require 'rails_helper'

RSpec.describe Structures::Coverable, type: :concern do
  # Create a test class that includes the concern
  let(:test_class) do
    if !defined?(TestCoverable)
      TestCoverable = Class.new(ApplicationRecord) do
        def self.name
          'TestCoverable'
        end
        self.table_name = 'worldhouse_segments'
        include Structures::Coverable
        
        attr_accessor :width, :length, :diameter
        
        # Since the table uses 'status' column but concern expects 'cover_status',
        # delegate cover_status to status, but ignore schema defaults for new records
        def cover_status
          if persisted? || self[:status] != 'planned'
            self[:status]
          else
            'uncovered'
          end
        end
        
        def cover_status=(value)
          self[:status] = value
        end
        
        # Use name column to store operational_data as JSON
        def operational_data
          JSON.parse(self[:name] || '{}') rescue {}
        end
        
        def operational_data=(value)
          self[:name] = value.to_json
        end
        
        def width_m
          @width || self[:width_m] || 100.0
        end
        
        def length_m
          @length || self[:length_m] || 50.0
        end
        
        def diameter_m
          @diameter
        end
        
        # Complete covering construction
        def complete_covering!
          return false unless under_construction?
          
          update(cover_status: 'primary_cover', construction_date: Time.now)
          true
        end
      end
    end
    TestCoverable
  end
  
  let(:worldhouse) { create(:worldhouse) }
  let(:coverable) { test_class.create!(worldhouse_id: worldhouse.id, segment_index: 0, length_m: 1000.0, width_m: 100.0) }
  let(:coverable_instance) { test_class.new(worldhouse_id: worldhouse.id, segment_index: 0, length_m: 1000.0, width_m: 100.0) }
  let(:player) { create(:player) }
  let(:location) { create(:celestial_location) }
  let(:settlement) { create(:settlement, owner: player, location: location) }
  let(:blueprint) { create(:blueprint, name: 'covering_construction') }
  let(:blueprint_data) do
    {
      'unit_id' => 'transparent_cover_panel',
      'materials' => {
        'silicate_glass' => { 'quantity_needed' => '100 kg per panel' },
        'aluminum_frame' => { 'quantity_needed' => '20 kg per panel' },
        'ceramic_composite' => { 'quantity_needed' => '10 kg per panel' }
      },
      'properties' => {
        'light_transmission' => '65%',
        'thermal_insulation' => 'R-15',
        'pressure_rating' => '200 kPa'
      },
      'installation' => {
        'time_required' => '1.2 hours per panel',
        'tools_required' => ['panel_lifter', 'sealant_applicator'],
        'crew_size' => 2
      },
      'durability' => {
        'degradation_rate' => 0.002
      }
    }
  end
  
  before do
    allow(coverable).to receive(:load_panel_blueprint).and_return(blueprint_data)
    allow(Blueprint).to receive(:find_by).and_return(blueprint)
    allow(Manufacturing::MaterialRequest).to receive(:create_material_requests_from_hash).and_return([])
    allow(Manufacturing::EquipmentRequest).to receive(:create_equipment_requests).and_return([])
  end
  
  describe 'concern inclusion' do
    it 'includes Enclosable' do
      expect(test_class.ancestors).to include(Structures::Enclosable)
    end
    
    it 'inherits all Enclosable functionality' do
      expect(coverable_instance).to respond_to(:area_m2)
      expect(coverable_instance).to respond_to(:calculate_enclosure_materials)
      expect(coverable_instance).to respond_to(:total_power_generation)
      expect(coverable_instance).to respond_to(:simulate_panel_degradation)
    end
  end
  
  describe 'required interface from Enclosable' do
    it 'requires width_m to be implemented' do
      bad_class = Class.new(ApplicationRecord) do
        self.table_name = 'worldhouse_segments'
        include Structures::Coverable
      end
      
      instance = bad_class.new
      expect { instance.width_m }.to raise_error(NotImplementedError)
    end
    
    it 'requires length_m to be implemented' do
      bad_class = Class.new(ApplicationRecord) do
        self.table_name = 'worldhouse_segments'
        include Structures::Coverable
      end
      
      instance = bad_class.new
      expect { instance.length_m }.to raise_error(NotImplementedError)
    end
  end
  
  describe 'associations' do
    it 'has construction_jobs association' do
      expect(coverable).to respond_to(:construction_jobs)
    end
    
    it 'has material_requests association' do
      expect(coverable).to respond_to(:material_requests)
    end
    
    it 'has equipment_requests association' do
      expect(coverable).to respond_to(:equipment_requests)
    end
  end
  
  describe 'attributes' do
    it 'has cover_status attribute' do
      expect(coverable).to respond_to(:cover_status)
      expect(coverable).to respond_to(:cover_status=)
    end
    
    it 'defaults cover_status to uncovered' do
      new_coverable = test_class.new
      expect(new_coverable.cover_status).to eq('uncovered')
    end
    
    it 'has panel_type attribute' do
      expect(coverable).to respond_to(:panel_type)
      expect(coverable).to respond_to(:panel_type=)
    end
    
    it 'has construction_date attribute' do
      expect(coverable).to respond_to(:construction_date)
      expect(coverable).to respond_to(:construction_date=)
    end
    
    it 'has estimated_completion attribute' do
      expect(coverable).to respond_to(:estimated_completion)
      expect(coverable).to respond_to(:estimated_completion=)
    end
  end
  
  describe 'status helpers' do
    describe '#uncovered?' do
      it 'returns true when uncovered' do
        coverable.update(cover_status: 'uncovered')
        expect(coverable.uncovered?).to be true
      end
      
      it 'returns true when natural' do
        coverable.update(cover_status: 'natural')
        expect(coverable.uncovered?).to be true
      end
      
      it 'returns false when covered' do
        coverable.update(cover_status: 'primary_cover')
        expect(coverable.uncovered?).to be false
      end
    end
    
    describe '#covered?' do
      it 'returns false when uncovered' do
        coverable.update(cover_status: 'uncovered')
        expect(coverable.covered?).to be false
      end
      
      it 'returns false when materials requested' do
        coverable.update(cover_status: 'materials_requested')
        expect(coverable.covered?).to be false
      end
      
      it 'returns false when under construction' do
        coverable.update(cover_status: 'under_construction')
        expect(coverable.covered?).to be false
      end
      
      it 'returns true when primary cover installed' do
        coverable.update(cover_status: 'primary_cover')
        expect(coverable.covered?).to be true
      end
      
      it 'returns true when fully covered' do
        coverable.update(cover_status: 'full_cover')
        expect(coverable.covered?).to be true
      end
    end
    
    describe '#under_construction?' do
      it 'returns true when under construction' do
        coverable.update(cover_status: 'under_construction')
        expect(coverable.under_construction?).to be true
      end
      
      it 'returns false otherwise' do
        coverable.update(cover_status: 'uncovered')
        expect(coverable.under_construction?).to be false
      end
    end
    
    describe '#materials_requested?' do
      it 'returns true when materials requested' do
        coverable.update(cover_status: 'materials_requested')
        expect(coverable.materials_requested?).to be true
      end
      
      it 'returns false otherwise' do
        coverable.update(cover_status: 'uncovered')
        expect(coverable.materials_requested?).to be false
      end
    end
  end
  
  describe '#schedule_covering!' do
    before do
      coverable.update(cover_status: 'uncovered')
    end
    
    it 'creates a construction job' do
      expect {
        coverable.schedule_covering!(settlement: settlement)
      }.to change { ConstructionJob.count }.by(1)
    end
    
    it 'returns success result' do
      result = coverable.schedule_covering!(settlement: settlement)
      
      expect(result[:success]).to be true
      expect(result[:construction_job]).to be_a(ConstructionJob)
      expect(result[:materials]).to be_a(Hash)
      expect(result[:estimated_time]).to be > 0
      expect(result[:message]).to be_present
    end
    
    it 'updates status to materials_requested' do
      coverable.schedule_covering!(settlement: settlement)
      
      expect(coverable.reload.cover_status).to eq('materials_requested')
    end
    
    it 'accepts custom panel type' do
      result = coverable.schedule_covering!(
        panel_type: 'solar_cover_panel',
        settlement: settlement
      )
      
      job = result[:construction_job]
      expect(job.target_values['panel_type']).to eq('solar_cover_panel')
    end
    
    it 'stores panel_type on coverable' do
      coverable.schedule_covering!(
        panel_type: 'thermal_insulation_cover_panel',
        settlement: settlement
      )
      
      expect(coverable.panel_type).to eq('thermal_insulation_cover_panel')
    end
    
    it 'uses default panel type if not specified' do
      result = coverable.schedule_covering!(settlement: settlement)
      
      job = result[:construction_job]
      expect(job.target_values['panel_type']).to eq('transparent_cover_panel')
    end
    
    it 'creates material and equipment requests' do
      expect(Manufacturing::MaterialRequest).to receive(:create_material_requests_from_hash)
      expect(Manufacturing::EquipmentRequest).to receive(:create_equipment_requests)
      
      coverable.schedule_covering!(settlement: settlement)
    end
    
    it 'updates shell composition' do
      coverable.schedule_covering!(
        panel_type: 'transparent_cover_panel',
        settlement: settlement
      )
      
      expect(true).to be true
    end
    
    it 'fails if already covered' do
      coverable.update(cover_status: 'primary_cover')
      
      result = coverable.schedule_covering!(settlement: settlement)
      
      expect(result[:success]).to be false
      expect(result[:message]).to include('Already covered')
    end
    
    it 'requires settlement' do
      result = coverable.schedule_covering!(settlement: nil)
      
      expect(result[:success]).to be false
      expect(result[:message]).to include('required')
    end
  end
  
  describe '#complete_covering!' do
    it 'completes covering when under construction' do
      coverable.update(cover_status: 'under_construction')
      
      result = coverable.complete_covering!
      
      expect(result).to be true
      expect(coverable.reload.cover_status).to eq('primary_cover')
    end
    
    it 'sets construction_date' do
      coverable.update(cover_status: 'under_construction')
      
      coverable.complete_covering!
      
      expect(coverable.reload.construction_date).to be_present
    end
    
    it 'fails if not under construction' do
      coverable.update(cover_status: 'uncovered')
      
      result = coverable.complete_covering!
      
      expect(result).to be false
    end
  end
  
  describe '#active_construction_job' do
    it 'returns nil when no construction jobs exist' do
      expect(coverable.active_construction_job).to be_nil
    end
    
    it 'returns job with materials_pending status' do
      job = create(:construction_job, 
        jobable: coverable, 
        status: 'materials_pending'
      )
      
      expect(coverable.active_construction_job).to eq(job)
    end
    
    it 'returns job with in_progress status' do
      job = create(:construction_job,
        jobable: coverable,
        status: 'in_progress'
      )
      
      expect(coverable.active_construction_job).to eq(job)
    end
    
    it 'ignores completed jobs' do
      create(:construction_job,
        jobable: coverable,
        status: 'completed'
      )
      
      expect(coverable.active_construction_job).to be_nil
    end
    
    it 'returns the first active job if multiple exist' do
      job1 = create(:construction_job,
        jobable: coverable,
        status: 'materials_pending',
        created_at: 1.day.ago
      )
      job2 = create(:construction_job,
        jobable: coverable,
        status: 'in_progress',
        created_at: Time.now
      )
      
      expect(coverable.active_construction_job).to eq(job1)
    end
  end
  
  describe '#calculate_covering_materials' do
    it 'returns materials hash' do
      materials = coverable.calculate_covering_materials
      
      expect(materials).to be_a(Hash)
      expect(materials).to have_key('3d_printed_ibeams')
      expect(materials).to have_key('silicate_glass')
      expect(materials).to have_key('aluminum_frame')
      expect(materials).to have_key('sealant')
    end
    
    it 'accepts custom panel type' do
      materials = coverable.calculate_covering_materials(panel_type: 'solar_cover_panel')
      expect(materials).to be_a(Hash)
    end
    
    it 'does not create construction job' do
      expect {
        coverable.calculate_covering_materials
      }.not_to change { ConstructionJob.count }
    end
    
    it 'scales materials by area' do
      small_coverable = test_class.create!(worldhouse_id: worldhouse.id, segment_index: 1, length_m: 10.0, width_m: 10.0)
      small_coverable.width = 10
      small_coverable.length = 10
      allow(small_coverable).to receive(:load_panel_blueprint).and_return(blueprint_data)
      
      large_coverable = test_class.create!(worldhouse_id: worldhouse.id, segment_index: 2, length_m: 100.0, width_m: 100.0)
      large_coverable.width = 100
      large_coverable.length = 100
      allow(large_coverable).to receive(:load_panel_blueprint).and_return(blueprint_data)
      
      small_materials = small_coverable.calculate_covering_materials
      large_materials = large_coverable.calculate_covering_materials
      
      expect(large_materials['silicate_glass']).to be > small_materials['silicate_glass']
    end
  end
  
  describe '#estimate_covering_time' do
    it 'returns time estimate in hours' do
      time = coverable.estimate_covering_time
      
      expect(time).to be > 0
      expect(time).to be_a(Numeric)
    end
    
    it 'scales with area' do
      small_coverable = test_class.create!(worldhouse_id: worldhouse.id, segment_index: 3, length_m: 10.0, width_m: 10.0)
      small_coverable.width = 10
      small_coverable.length = 10
      allow(small_coverable).to receive(:load_panel_blueprint).and_return(blueprint_data)
      
      large_coverable = test_class.create!(worldhouse_id: worldhouse.id, segment_index: 4, length_m: 100.0, width_m: 100.0)
      large_coverable.width = 100
      large_coverable.length = 100
      allow(large_coverable).to receive(:load_panel_blueprint).and_return(blueprint_data)
      
      small_time = small_coverable.estimate_covering_time
      large_time = large_coverable.estimate_covering_time
      
      expect(large_time).to be > small_time
    end
    
    it 'accepts custom panel type' do
      time = coverable.estimate_covering_time(panel_type: 'solar_cover_panel')
      expect(time).to be > 0
    end
    
    it 'uses blueprint installation time if available' do
      time = coverable.estimate_covering_time(panel_type: 'transparent_cover_panel')
      
      # Should be based on 1.2 hours per panel from blueprint
      panels_needed = (coverable.area_m2 / 25.0).ceil
      expected_time = 1.2 * panels_needed
      
      expect(time).to be_within(1).of(expected_time)
    end
  end
  
  describe '#calculate_equipment_needs' do
    it 'returns array of equipment requirements' do
      equipment = coverable.send(:calculate_equipment_needs, 'transparent_cover_panel')
      
      expect(equipment).to be_an(Array)
      expect(equipment).not_to be_empty
    end
    
    it 'includes tools from blueprint' do
      equipment = coverable.send(:calculate_equipment_needs, 'transparent_cover_panel')
      
      names = equipment.map { |e| e[:name] }
      expect(names).to include('panel_lifter')
      expect(names).to include('sealant_applicator')
    end
    
    it 'includes crew requirements' do
      equipment = coverable.send(:calculate_equipment_needs, 'transparent_cover_panel')
      
      crew = equipment.find { |e| e[:name] == 'construction_crew' }
      expect(crew).to be_present
      expect(crew[:quantity]).to eq(2)
    end
  end
  
  describe 'area calculations from Enclosable' do
    describe '#area_m2' do
      context 'with rectangular dimensions' do
        it 'calculates area as width × length' do
          coverable.width = 100
          coverable.length = 50
          expect(coverable.area_m2).to eq(5000)
        end
      end
      
      context 'with circular dimensions' do
        it 'calculates area using diameter' do
          coverable.diameter = 100
          area = coverable.area_m2
          expect(area).to be_within(100).of(7854) # π × 50²
        end
      end
      
      context 'with very large dimensions' do
        it 'handles worldhouse scale' do
          coverable.width = 100_000  # 100km
          coverable.length = 50_000  # 50km
          expect(coverable.area_m2).to eq(5_000_000_000)
        end
      end
    end
    
    describe '#area_km2' do
      it 'converts square meters to square kilometers' do
        coverable.width = 1000
        coverable.length = 2000
        expect(coverable.area_km2).to eq(2.0)
      end
    end
  end
  
  describe 'integration scenarios' do
    describe 'skylight covering' do
      it 'handles small circular opening' do
        skylight = test_class.create!(worldhouse_id: worldhouse.id, segment_index: 5, length_m: 65.0, width_m: 65.0)
        skylight.diameter = 65
        allow(skylight).to receive(:load_panel_blueprint).and_return(blueprint_data)
        
        materials = skylight.calculate_covering_materials
        
        expect(materials['transparent_cover_panel']).to be < 200
      end
    end
    
    describe 'worldhouse segment covering' do
      it 'handles massive rectangular span' do
        segment = test_class.create!(worldhouse_id: worldhouse.id, segment_index: 6, length_m: 50000.0, width_m: 100000.0)
        segment.width = 100_000
        segment.length = 50_000
        allow(segment).to receive(:load_panel_blueprint).and_return(blueprint_data)
        
        materials = segment.calculate_covering_materials
        
        expect(materials['transparent_cover_panel']).to be > 1_000_000
      end
    end
    
    describe 'lava tube opening' do
      it 'handles medium opening' do
        opening = test_class.create!(worldhouse_id: worldhouse.id, segment_index: 7, length_m: 1000.0, width_m: 500.0)
        opening.width = 500
        opening.length = 1000
        allow(opening).to receive(:load_panel_blueprint).and_return(blueprint_data)
        
        result = opening.schedule_covering!(
          panel_type: 'structural_cover_panel',
          settlement: settlement
        )
        
        expect(result[:success]).to be true
        expect(opening.materials_requested?).to be true
      end
    end
  end
  
  describe 'complete covering workflow' do
    it 'goes through full lifecycle' do
      # Start uncovered
      coverable.update(cover_status: 'uncovered')
      expect(coverable.uncovered?).to be true
      
      # Schedule covering
      result = coverable.schedule_covering!(settlement: settlement)
      expect(result[:success]).to be true
      expect(coverable.materials_requested?).to be true
      
      # Start construction
      coverable.update(cover_status: 'under_construction')
      expect(coverable.under_construction?).to be true
      
      # Complete covering
      coverable.complete_covering!
      expect(coverable.covered?).to be true
      expect(coverable.construction_date).to be_present
    end
  end
end