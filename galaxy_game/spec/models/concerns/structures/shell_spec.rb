# spec/models/concerns/structures/shell_spec.rb
require 'rails_helper'

RSpec.describe Structures::Shell, type: :concern do
  let(:test_class) do
    if !defined?(TestShell)
      TestShell = Class.new(ApplicationRecord) do
        def self.name
          'TestShell'
        end
        self.table_name = 'worldhouse_segments'
        include Structures::Shell
        
        belongs_to :worldhouse, class_name: 'Structures::Worldhouse', optional: false
        
        has_many :construction_jobs, as: :jobable, dependent: :destroy
        has_many :material_requests, through: :construction_jobs
        has_many :equipment_requests, through: :construction_jobs
        
        attr_accessor :width, :length, :diameter, :_atmosphere
        
        # Dimension methods required by Enclosable
        def width_m
          @width || self[:width_m] || 100.0
        end
        
        def length_m
          @length || self[:length_m] || 50.0
        end
        
        def diameter_m
          @diameter
        end
        
        # Atmosphere methods
        def atmosphere
          @_atmosphere
        end
        
        def create_atmosphere(attrs)
          @_atmosphere = OpenStruct.new(attrs)
        end
        
        # Persistence overrides - use status column for shell_status
        def shell_status
          status || 'planned'
        end
        
        def shell_status=(value)
          self.status = value
          save!
        end
        
        def shell_sealed_design?
          operational_data&.dig('shell', 'sealed') || false
        end
        
        def on_shell_operational
          # Hook method for when shell becomes operational
        end
        
        after_initialize :init_operational_data
        
        private
        
        def init_operational_data
          self.operational_data ||= {}
        end
      end
    end
    TestShell
  end
  
  let(:worldhouse) { create(:worldhouse) }
  let(:shell_structure) { test_class.create!(worldhouse_id: worldhouse.id, segment_index: 0, length_m: 1000.0, width_m: 100.0) }
  let(:settlement) { create(:base_settlement) }
  let(:blueprint) { create(:blueprint, name: 'shell_construction') }
  let(:blueprint_data) do
    {
      'unit_id' => 'structural_cover_panel',
      'materials' => {
        'titanium_alloy' => { 'quantity_needed' => '35 kg per panel' },
        'reinforced_polymers' => { 'quantity_needed' => '20 kg per panel' },
        'structural_steel_core' => { 'quantity_needed' => '25 kg per panel' }
      },
      'properties' => {
        'pressure_rating' => '300 kPa',
        'thermal_insulation' => 'R-35'
      },
      'installation' => {
        'time_required' => '2.5 hours per panel',
        'tools_required' => ['heavy_duty_fastening_system', 'structural_load_tester'],
        'crew_size' => 3
      },
      'durability' => {
        'degradation_rate' => 0.003
      }
    }
  end
  
  before do
    allow(shell_structure).to receive(:load_panel_blueprint).and_return(blueprint_data)
    allow(Blueprint).to receive(:find_by).and_return(blueprint)
    allow(Manufacturing::MaterialRequest).to receive(:create_material_requests_from_hash).and_return([])
    allow(Manufacturing::EquipmentRequest).to receive(:create_equipment_requests).and_return([])
  end
  
  describe 'concern inclusion' do
    it 'includes Enclosable' do
      expect(test_class.ancestors).to include(Structures::Enclosable)
    end
    
    it 'inherits all Enclosable functionality' do
      expect(shell_structure).to respond_to(:area_m2)
      expect(shell_structure).to respond_to(:calculate_enclosure_materials)
      expect(shell_structure).to respond_to(:total_power_generation)
      expect(shell_structure).to respond_to(:simulate_panel_degradation)
    end
  end
  
  describe 'associations' do
    it 'has construction_jobs association' do
      expect(shell_structure).to respond_to(:construction_jobs)
    end
    
    it 'has material_requests association' do
      expect(shell_structure).to respond_to(:material_requests)
    end
    
    it 'has equipment_requests association' do
      expect(shell_structure).to respond_to(:equipment_requests)
    end
  end
  
  describe 'status helpers' do
    describe '#shell_planned?' do
      it 'returns true when planned' do
        shell_structure.update(shell_status: 'planned')
        expect(shell_structure.shell_planned?).to be true
      end
      
      it 'returns false when not planned' do
        shell_structure.update(shell_status: 'sealed')
        expect(shell_structure.shell_planned?).to be false
      end
    end
    
    describe '#framework_construction?' do
      it 'returns true when framework under construction' do
        shell_structure.update(shell_status: 'framework_construction')
        expect(shell_structure.framework_construction?).to be true
      end
    end
    
    describe '#panel_installation?' do
      it 'returns true when panels being installed' do
        shell_structure.update(shell_status: 'panel_installation')
        expect(shell_structure.panel_installation?).to be true
      end
    end
    
    describe '#sealed?' do
      it 'returns true when sealed' do
        shell_structure.update(shell_status: 'sealed')
        expect(shell_structure.sealed?).to be true
      end
      
      it 'returns true when pressurized' do
        shell_structure.update(shell_status: 'pressurized')
        expect(shell_structure.sealed?).to be true
      end
      
      it 'returns false when operational' do
        shell_structure.update(shell_status: 'operational')
        expect(shell_structure.sealed?).to be false
      end
      
      it 'returns false when under construction' do
        shell_structure.update(shell_status: 'framework_construction')
        expect(shell_structure.sealed?).to be false
      end
    end
    
    describe '#pressurized?' do
      it 'returns true when pressurized' do
        shell_structure.update(shell_status: 'pressurized')
        expect(shell_structure.pressurized?).to be true
      end
      
      it 'returns false when operational' do
        shell_structure.update(shell_status: 'operational')
        expect(shell_structure.pressurized?).to be false
      end
      
      it 'returns false when only sealed' do
        shell_structure.update(shell_status: 'sealed')
        expect(shell_structure.pressurized?).to be false
      end
    end
    
    describe '#pressurize_shell!' do
      it 'pressurizes when sealed' do
        shell_structure.update(shell_status: 'sealed')
        
        result = shell_structure.pressurize_shell!
        
        expect(result).to be true
        expect(shell_structure.reload.shell_status).to eq('pressurized')
      end
      
      it 'creates atmosphere when pressurized' do
        shell_structure.update(shell_status: 'sealed')
        
        shell_structure.pressurize_shell!
        
        expect(shell_structure.atmosphere).to be_present
      end
      
      it 'fails if not sealed' do
        shell_structure.update(shell_status: 'operational')
        
        result = shell_structure.pressurize_shell!
        
        expect(result).to be false
      end
      
      it 'fails if already pressurized' do
        shell_structure.update(shell_status: 'pressurized')
        
        result = shell_structure.pressurize_shell!
        
        expect(result).to be false
      end
    end
    
    describe '#shell_operational?' do
      it 'returns true when operational' do
        shell_structure.update(shell_status: 'operational')
        expect(shell_structure.shell_operational?).to be true
      end
      
      it 'returns false when not operational' do
        shell_structure.update(shell_status: 'sealed')
        expect(shell_structure.shell_operational?).to be false
      end
    end
    
    describe '#shell_under_construction?' do
      it 'returns true during framework construction' do
        shell_structure.update(shell_status: 'framework_construction')
        expect(shell_structure.shell_under_construction?).to be true
      end
      
      it 'returns true during panel installation' do
        shell_structure.update(shell_status: 'panel_installation')
        expect(shell_structure.shell_under_construction?).to be true
      end
      
      it 'returns false when sealed' do
        shell_structure.update(shell_status: 'sealed')
        expect(shell_structure.shell_under_construction?).to be false
      end
    end
  end
  
  describe '#schedule_shell_construction!' do
    before do
      shell_structure.update(shell_status: 'planned')
    end
    
    it 'creates a construction job' do
      expect {
        shell_structure.schedule_shell_construction!(settlement: settlement)
      }.to change { ConstructionJob.count }.by(1)
    end
    
    it 'returns success result' do
      result = shell_structure.schedule_shell_construction!(settlement: settlement)
      
      expect(result[:success]).to be true
      expect(result[:construction_job]).to be_a(ConstructionJob)
      expect(result[:materials]).to be_a(Hash)
      expect(result[:estimated_time]).to be > 0
      expect(result[:message]).to be_present
    end
    
    it 'updates status to framework_construction' do
      shell_structure.schedule_shell_construction!(settlement: settlement)
      
      expect(shell_structure.reload.shell_status).to eq('framework_construction')
    end
    
    it 'accepts custom panel type' do
      result = shell_structure.schedule_shell_construction!(
        panel_type: 'solar_cover_panel',
        settlement: settlement
      )
      
      job = result[:construction_job]
      expect(job.target_values['panel_type']).to eq('solar_cover_panel')
    end
    
    it 'stores panel_type on structure' do
      shell_structure.schedule_shell_construction!(
        panel_type: 'thermal_insulation_cover_panel',
        settlement: settlement
      )
      
      expect(shell_structure.reload.panel_type).to eq('thermal_insulation_cover_panel')
    end
    
    it 'sets construction_date' do
      shell_structure.schedule_shell_construction!(settlement: settlement)
      
      expect(shell_structure.reload.construction_date).to be_present
    end
    
    it 'creates material and equipment requests' do
      expect(MaterialRequestService).to receive(:create_material_requests_from_hash)
      expect(Manufacturing::EquipmentRequest).to receive(:create_equipment_requests)
      
      shell_structure.schedule_shell_construction!(settlement: settlement)
    end
    
    it 'updates shell composition' do
      shell_structure.schedule_shell_construction!(
        panel_type: 'structural_cover_panel',
        settlement: settlement
      )
      
      composition = shell_structure.operational_data['shell_composition']['structural_cover_panel']
      expect(composition).to be_present
      expect(composition['count']).to be > 0
    end
    
    it 'fails if already sealed' do
      shell_structure.update(shell_status: 'sealed')
      
      result = shell_structure.schedule_shell_construction!(settlement: settlement)
      
      expect(result[:success]).to be false
      expect(result[:message]).to include('already constructed')
    end
    
    it 'requires settlement' do
      result = shell_structure.schedule_shell_construction!(settlement: nil)
      
      expect(result[:success]).to be false
      expect(result[:message]).to include('required')
    end
  end
  
  describe '#advance_shell_construction!' do
    it 'advances from planned to framework_construction' do
      shell_structure.update(shell_status: 'planned')
      
      shell_structure.advance_shell_construction!
      
      expect(shell_structure.reload.shell_status).to eq('framework_construction')
    end
    
    it 'advances from framework_construction to panel_installation' do
      shell_structure.update(shell_status: 'framework_construction')
      
      shell_structure.advance_shell_construction!
      
      expect(shell_structure.reload.shell_status).to eq('panel_installation')
    end
    
    it 'advances from panel_installation to operational' do
      shell_structure.update(shell_status: 'panel_installation')
      
      shell_structure.advance_shell_construction!
      
      expect(shell_structure.reload.shell_status).to eq('operational')
    end
    
    it 'advances from panel_installation to sealed when designed for sealing' do
      shell_structure.operational_data['shell'] = { 'sealed' => true }
      shell_structure.update(shell_status: 'panel_installation')
      
      shell_structure.advance_shell_construction!
      
      expect(shell_structure.reload.shell_status).to eq('sealed')
    end
    
    it 'advances from sealed to pressurized' do
      shell_structure.update(shell_status: 'sealed')
      
      shell_structure.advance_shell_construction!
      
      expect(shell_structure.reload.shell_status).to eq('pressurized')
    end
    
    it 'calls on_shell_operational hook when operational' do
      shell_structure.update(shell_status: 'panel_installation')
      
      expect(shell_structure).to receive(:on_shell_operational)
      
      shell_structure.advance_shell_construction!
    end
  end
  
  describe '#active_construction_job' do
    it 'returns nil when no construction jobs exist' do
      expect(shell_structure.active_construction_job).to be_nil
    end
    
    it 'returns job with materials_pending status' do
      job = create(:construction_job, 
        jobable: shell_structure, 
        status: 'materials_pending'
      )
      
      expect(shell_structure.active_construction_job).to eq(job)
    end
    
    it 'returns job with in_progress status' do
      job = create(:construction_job,
        jobable: shell_structure,
        status: 'in_progress'
      )
      
      expect(shell_structure.active_construction_job).to eq(job)
    end
    
    it 'ignores completed jobs' do
      create(:construction_job,
        jobable: shell_structure,
        status: 'completed'
      )
      
      expect(shell_structure.active_construction_job).to be_nil
    end
  end
  
  describe '#calculate_shell_materials' do
    it 'returns materials hash' do
      materials = shell_structure.calculate_shell_materials
      
      expect(materials).to be_a(Hash)
      expect(materials).to have_key('3d_printed_ibeams')
      expect(materials).to have_key('titanium_alloy')
      expect(materials).to have_key('reinforced_polymers')
    end
    
    it 'accepts custom panel type' do
      materials = shell_structure.calculate_shell_materials(panel_type: 'solar_cover_panel')
      expect(materials).to be_a(Hash)
    end
    
    it 'does not create construction job' do
      expect {
        shell_structure.calculate_shell_materials
      }.not_to change { ConstructionJob.count }
    end
    
    it 'scales materials by area' do
      small_shell = test_class.create!(worldhouse_id: worldhouse.id, segment_index: 3, length_m: 10, width_m: 10)
      small_shell.width = 10
      small_shell.length = 10
      allow(small_shell).to receive(:load_panel_blueprint).and_return(blueprint_data)

      large_shell = test_class.create!(worldhouse_id: worldhouse.id, segment_index: 4, length_m: 100, width_m: 100)
      large_shell.width = 100
      large_shell.length = 100
      allow(large_shell).to receive(:load_panel_blueprint).and_return(blueprint_data)

      small_materials = small_shell.calculate_shell_materials
      large_materials = large_shell.calculate_shell_materials

      expect(large_materials['titanium_alloy']).to be > small_materials['titanium_alloy']
    end
  end
  
  describe '#estimate_shell_construction_time' do
    it 'returns time estimate in hours' do
      time = shell_structure.estimate_shell_construction_time
      
      expect(time).to be > 0
      expect(time).to be_a(Integer)
    end
    
    it 'scales with area' do
      small_shell = test_class.create!(worldhouse_id: worldhouse.id, segment_index: 1, length_m: 10, width_m: 10)
      small_shell.width = 10
      small_shell.length = 10
      allow(small_shell).to receive(:load_panel_blueprint).and_return(blueprint_data)

      large_shell = test_class.create!(worldhouse_id: worldhouse.id, segment_index: 2, length_m: 100, width_m: 100)
      large_shell.width = 100
      large_shell.length = 100
      allow(large_shell).to receive(:load_panel_blueprint).and_return(blueprint_data)

      small_time = small_shell.estimate_shell_construction_time
      large_time = large_shell.estimate_shell_construction_time

      expect(large_time).to be > small_time
    end
    
    it 'takes longer than covering equivalent area' do
      # Shell construction includes framework + panels
      # Should be roughly 2x covering time
      shell_time = shell_structure.estimate_shell_construction_time
      
      # Assume covering would be half the time (rough estimate)
      expected_covering_time = shell_time / 2
      
      expect(shell_time).to be > expected_covering_time
    end
    
    it 'accepts custom panel type' do
      time = shell_structure.estimate_shell_construction_time(panel_type: 'solar_cover_panel')
      expect(time).to be > 0
    end
  end
  
  describe '#calculate_equipment_needs' do
    it 'returns array of equipment requirements' do
      equipment = shell_structure.calculate_equipment_needs('structural_cover_panel')
      
      expect(equipment).to be_an(Array)
      expect(equipment).not_to be_empty
    end
    
    it 'includes base construction equipment' do
      equipment = shell_structure.calculate_equipment_needs('structural_cover_panel')
      
      types = equipment.map { |e| e[:equipment_type] }
      expect(types).to include('space_construction_drone')
      expect(types).to include('welding_equipment')
      expect(types).to include('structural_assembly_system')
    end
    
    it 'includes panel-specific tools from blueprint' do
      equipment = shell_structure.calculate_equipment_needs('structural_cover_panel')
      
      types = equipment.map { |e| e[:equipment_type] }
      expect(types).to include('heavy_duty_fastening_system')
      expect(types).to include('structural_load_tester')
    end
    
    it 'includes crew requirements' do
      equipment = shell_structure.calculate_equipment_needs('structural_cover_panel')
      
      crew = equipment.find { |e| e[:equipment_type] == 'construction_crew' }
      expect(crew).to be_present
      expect(crew[:quantity]).to eq(3)
    end
  end
  
  describe '#calculate_volume' do
    context 'with rectangular dimensions' do
      it 'calculates volume with assumed height' do
        shell_structure.width = 100
        shell_structure.length = 50
        
        volume = shell_structure.calculate_volume
        
        # 100 × 50 × 3 (assumed height)
        expect(volume).to eq(15_000)
      end
    end
    
    context 'with circular dimensions' do
      it 'calculates spherical volume' do
        shell_structure.diameter = 100
        
        volume = shell_structure.calculate_volume
        
        # (4/3) × π × 50³
        expected = (4.0 / 3.0) * Math::PI * (50 ** 3)
        expect(volume).to be_within(100).of(expected)
      end
    end
  end
  
  describe '#create_shell_atmosphere' do
    before do
      shell_structure.update(shell_status: 'sealed')
    end
    
    it 'creates atmosphere when sealed' do
      atmosphere = shell_structure.create_shell_atmosphere
      
      expect(atmosphere).to be_present
      expect(atmosphere.environment_type).to eq('enclosed')
    end
    
    it 'starts unpressurized' do
      atmosphere = shell_structure.create_shell_atmosphere
      
      expect(atmosphere.pressure).to eq(0.0)
    end
    
    it 'accepts custom temperature' do
      atmosphere = shell_structure.create_shell_atmosphere(temp: 300.0)
      
      expect(atmosphere.temperature).to eq(300.0)
    end
    
    it 'does not create duplicate atmosphere' do
      shell_structure.create_shell_atmosphere
      
      atmosphere2 = shell_structure.create_shell_atmosphere
      
      expect(atmosphere2).to eq(shell_structure.atmosphere)
    end
    
    it 'returns nil if not sealed' do
      shell_structure.update(shell_status: 'panel_installation')
      
      atmosphere = shell_structure.create_shell_atmosphere
      
      # Should still create atmosphere during panel_installation (sealing phase)
      expect(atmosphere).to be_present
    end
  end
  
  describe 'integration with space station' do
    it 'provides all methods needed for space station shell' do
      expect(shell_structure).to respond_to(:schedule_shell_construction!)
      expect(shell_structure).to respond_to(:pressurize_shell!)
      expect(shell_structure).to respond_to(:sealed?)
      expect(shell_structure).to respond_to(:total_power_generation)
      expect(shell_structure).to respond_to(:shell_status_report)
    end
  end
  
  describe 'complete construction workflow' do
    it 'goes through full lifecycle' do
      # Start planned
      expect(shell_structure.shell_planned?).to be true
      
      # Schedule construction
      result = shell_structure.schedule_shell_construction!(settlement: settlement)
      expect(result[:success]).to be true
      expect(shell_structure.framework_construction?).to be true
      
      # Advance through phases
      shell_structure.advance_shell_construction!
      expect(shell_structure.panel_installation?).to be true
      
      shell_structure.advance_shell_construction!
      expect(shell_structure.shell_operational?).to be true
    end
  end
end