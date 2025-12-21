# spec/models/concerns/structures/enclosable_spec.rb
require 'rails_helper'

RSpec.describe Structures::Enclosable, type: :concern do
  # Create a test class that includes the concern
  let(:test_class) do
    # Give the class a name by assigning it to a constant
    stub_const('TestEnclosable', Class.new(ApplicationRecord) do
      self.table_name = 'worldhouse_segments'
      include Structures::Enclosable
      
      # Add the association - disable inverse_of since this is a test class
      belongs_to :worldhouse, class_name: 'Structures::Worldhouse', inverse_of: false, optional: false
      
      # For testing, we'll override the methods to use instance variables
      # but still provide defaults that satisfy NOT NULL constraints
      attr_accessor :_width, :_length, :_diameter
      
      def width_m
        @_width || self[:width_m] || 100.0
      end
      
      def length_m
        @_length || self[:length_m] || 50.0
      end
      
      def diameter_m
        @_diameter || self[:diameter_m]
      end
      
      # Setter methods to update instance variables
      def width=(val)
        @_width = val
      end
      
      def length=(val)
        @_length = val
      end
      
      def diameter=(val)
        @_diameter = val
      end
      
      # Ensure operational_data is initialized
      after_initialize :init_operational_data
      
      private
      
      def init_operational_data
        self.operational_data ||= {}
      end
    end)
  end
  
  # Create a worldhouse for the segments to belong to
  let(:worldhouse) { create(:worldhouse) }
  let(:enclosable) { test_class.create!(worldhouse: worldhouse, segment_index: 0, length_m: 100.0, width_m: 100.0) }
  
  let(:blueprint_data) do
    {
      'unit_id' => 'solar_cover_panel',
      'materials' => {
        'advanced_solar_cells' => { 'quantity_needed' => '10 kg per panel' },
        'graphene_layers' => { 'quantity_needed' => '3 kg per panel' },
        'reinforced_aluminum_frame' => { 'quantity_needed' => '12 kg per panel' }
      },
      'properties' => {
        'energy_output' => '10 kW per panel',
        'light_transmission' => '35%',
        'thermal_insulation' => 'R-20'
      },
      'dimensions' => {
        'standard_size' => '5m x 5m'
      },
      'durability' => {
        'degradation_rate' => 0.004
      }
    }
  end
  
  before do
    allow(enclosable).to receive(:load_panel_blueprint).and_return(blueprint_data)
    allow(Blueprint).to receive(:find_by).and_return(nil)
  end
  
  describe 'required interface' do
    it 'requires width_m to be implemented' do
      bad_class = stub_const('BadTestClass', Class.new(ApplicationRecord) do
        self.table_name = 'worldhouse_segments'
        include Structures::Enclosable
        belongs_to :worldhouse, class_name: 'Structures::Worldhouse', inverse_of: false
      end)
      
      instance = bad_class.new
      expect { instance.width_m }.to raise_error(NotImplementedError)
    end
    
    it 'requires length_m to be implemented' do
      bad_class = stub_const('BadTestClass2', Class.new(ApplicationRecord) do
        self.table_name = 'worldhouse_segments'
        include Structures::Enclosable
        belongs_to :worldhouse, class_name: 'Structures::Worldhouse', inverse_of: false
      end)
      
      instance = bad_class.new
      expect { instance.length_m }.to raise_error(NotImplementedError)
    end
  end
  
  describe '#area_m2' do
    context 'with rectangular dimensions' do
      it 'calculates area as width × length' do
        enclosable.width = 100
        enclosable.length = 50
        expect(enclosable.area_m2).to eq(5000)
      end
    end
    
    context 'with circular dimensions' do
      it 'calculates area using diameter' do
        enclosable.diameter = 100
        area = enclosable.area_m2
        expect(area).to be_within(100).of(7854) # π × 50²
      end
    end
    
    context 'with very large dimensions' do
      it 'handles worldhouse scale' do
        enclosable.width = 100_000  # 100km
        enclosable.length = 50_000  # 50km
        expect(enclosable.area_m2).to eq(5_000_000_000)
      end
    end
  end
  
  describe '#area_km2' do
    it 'converts square meters to square kilometers' do
      enclosable.width = 1000
      enclosable.length = 2000
      expect(enclosable.area_km2).to eq(2.0)
    end
    
    it 'handles small areas' do
      enclosable.width = 10
      enclosable.length = 10
      expect(enclosable.area_km2).to eq(0.0001)
    end
  end
  
  describe '#calculate_enclosure_materials' do
    before do
      enclosable.width = 100
      enclosable.length = 100
      # 10,000 m² = 400 panels (5m × 5m each = 25m² per panel)
    end
    
    it 'calculates materials from blueprint data' do
      materials = enclosable.calculate_enclosure_materials(panel_type: 'solar_cover_panel')
      
      expect(materials).to be_a(Hash)
      expect(materials).to have_key('3d_printed_ibeams')
      expect(materials).to have_key('advanced_solar_cells')
      expect(materials).to have_key('graphene_layers')
      expect(materials).to have_key('reinforced_aluminum_frame')
    end
    
    it 'scales materials by area' do
      small_enclosable = test_class.create!(worldhouse: worldhouse, segment_index: 1, length_m: 10.0, width_m: 10.0)
      small_enclosable.width = 10
      small_enclosable.length = 10
      allow(small_enclosable).to receive(:load_panel_blueprint).and_return(blueprint_data)
      
      large_enclosable = test_class.create!(worldhouse: worldhouse, segment_index: 2, length_m: 100.0, width_m: 100.0)
      large_enclosable.width = 100
      large_enclosable.length = 100
      allow(large_enclosable).to receive(:load_panel_blueprint).and_return(blueprint_data)
      
      small_materials = small_enclosable.calculate_enclosure_materials(panel_type: 'solar_cover_panel')
      large_materials = large_enclosable.calculate_enclosure_materials(panel_type: 'solar_cover_panel')
      
      expect(large_materials['advanced_solar_cells']).to be > small_materials['advanced_solar_cells']
    end
    
    it 'includes panel count in materials' do
      materials = enclosable.calculate_enclosure_materials(panel_type: 'solar_cover_panel')
      
      # 10,000 m² / 25 m² per panel = 400 panels
      expect(materials['solar_cover_panel']).to eq(400)
    end
    
    it 'includes ibeam calculations' do
      materials = enclosable.calculate_enclosure_materials(panel_type: 'solar_cover_panel')
      
      expect(materials['3d_printed_ibeams']).to be > 0
    end
  end
  
  describe '#update_shell_composition' do
    it 'stores panel composition in operational_data' do
      enclosable.update_shell_composition('solar_cover_panel', 400, 10_000.0)
      
      composition = enclosable.operational_data['shell_composition']['solar_cover_panel']
      expect(composition['count']).to eq(400)
      expect(composition['total_area_m2']).to eq(10_000.0)
      expect(composition['health_percentage']).to eq(100.0)
      expect(composition['failed_count']).to eq(0)
    end
    
    it 'can track multiple panel types' do
      enclosable.update_shell_composition('solar_cover_panel', 300, 7500.0)
      enclosable.update_shell_composition('transparent_cover_panel', 100, 2500.0)
      
      composition = enclosable.operational_data['shell_composition']
      expect(composition.keys).to contain_exactly('solar_cover_panel', 'transparent_cover_panel')
    end
  end
  
  describe '#total_power_generation' do
    before do
      enclosable.operational_data = { 'shell_composition' => {} }
      enclosable.update_shell_composition('solar_cover_panel', 400, 10_000.0)
    end
    
    it 'calculates power from solar panels' do
      power = enclosable.total_power_generation
      
      # 400 panels × 10 kW per panel = 4000 kW
      expect(power).to eq(4000.0)
    end
    
    it 'returns 0 for non-solar panels' do
      non_solar_blueprint = blueprint_data.dup
      non_solar_blueprint['properties']['energy_output'] = nil
      allow(enclosable).to receive(:load_panel_blueprint).and_return(non_solar_blueprint)
      
      enclosable.operational_data = { 'shell_composition' => {} }
      enclosable.update_shell_composition('transparent_cover_panel', 400, 10_000.0)
      
      expect(enclosable.total_power_generation).to eq(0)
    end
    
    it 'accounts for failed panels' do
      composition = enclosable.operational_data['shell_composition']['solar_cover_panel']
      composition['failed_count'] = 50  # 50 failed panels
      enclosable.save!
      
      power = enclosable.total_power_generation
      
      # (400 - 50) panels × 10 kW = 3500 kW
      expect(power).to eq(3500.0)
    end
    
    it 'accounts for degradation' do
      composition = enclosable.operational_data['shell_composition']['solar_cover_panel']
      composition['health_percentage'] = 90.0  # 90% health
      enclosable.save!
      
      power = enclosable.total_power_generation
      
      # 400 panels × 10 kW × 0.90 = 3600 kW
      expect(power).to eq(3600.0)
    end
    
    it 'combines failures and degradation' do
      composition = enclosable.operational_data['shell_composition']['solar_cover_panel']
      composition['failed_count'] = 40
      composition['health_percentage'] = 85.0
      enclosable.save!
      
      power = enclosable.total_power_generation
      
      # (400 - 40) panels × 10 kW × 0.85 = 3060 kW
      expect(power).to eq(3060.0)
    end
  end
  
  describe '#simulate_panel_degradation' do
    before do
      enclosable.operational_data = { 'shell_composition' => {} }
      enclosable.update_shell_composition('solar_cover_panel', 400, 10_000.0)
    end
    
    it 'reduces health percentage over time' do
      initial_health = enclosable.operational_data.dig('shell_composition', 'solar_cover_panel', 'health_percentage')
      
      enclosable.simulate_panel_degradation(365) # 1 year
      
      new_health = enclosable.operational_data.dig('shell_composition', 'solar_cover_panel', 'health_percentage')
      expect(new_health).to be < initial_health
    end
    
    it 'uses degradation_rate from blueprint' do
      # degradation_rate: 0.004
      enclosable.simulate_panel_degradation(100)
      
      health = enclosable.operational_data.dig('shell_composition', 'solar_cover_panel', 'health_percentage')
      expected_health = 100.0 - (0.004 * 100)
      
      expect(health).to be_within(0.1).of(expected_health)
    end
    
    it 'can cause random panel failures' do
      allow(enclosable).to receive(:rand).and_return(0.001, 2) # Force a failure of 2 panels
      
      initial_failures = enclosable.operational_data.dig('shell_composition', 'solar_cover_panel', 'failed_count')
      
      enclosable.simulate_panel_degradation(365)
      
      new_failures = enclosable.operational_data.dig('shell_composition', 'solar_cover_panel', 'failed_count')
      expect(new_failures).to be > initial_failures
    end
    
    it 'health cannot go below 0' do
      enclosable.simulate_panel_degradation(100_000) # Extreme time
      
      health = enclosable.operational_data.dig('shell_composition', 'solar_cover_panel', 'health_percentage')
      expect(health).to be >= 0
    end
  end
  
  describe '#repair_panels' do
    before do
      enclosable.operational_data = { 'shell_composition' => {} }
      enclosable.update_shell_composition('solar_cover_panel', 400, 10_000.0)
      
      # Simulate some failures
      composition = enclosable.operational_data['shell_composition']['solar_cover_panel']
      composition['failed_count'] = 20
      enclosable.save!
    end
    
    it 'reduces failed_count' do
      result = enclosable.repair_panels('solar_cover_panel', 10)
      
      expect(result[:success]).to be true
      expect(result[:repaired_count]).to eq(10)
      
      failed_count = enclosable.operational_data.dig('shell_composition', 'solar_cover_panel', 'failed_count')
      expect(failed_count).to eq(10)
    end
    
    it 'cannot repair more than failed' do
      result = enclosable.repair_panels('solar_cover_panel', 50)
      
      expect(result[:repaired_count]).to eq(20) # Only 20 were failed
      
      failed_count = enclosable.operational_data.dig('shell_composition', 'solar_cover_panel', 'failed_count')
      expect(failed_count).to eq(0)
    end
    
    it 'returns materials needed for repair' do
      result = enclosable.repair_panels('solar_cover_panel', 10)
      
      expect(result[:materials_needed]).to be_a(Hash)
    end
  end
  
  describe '#replace_degraded_panels' do
    before do
      enclosable.operational_data = { 'shell_composition' => {} }
      enclosable.update_shell_composition('solar_cover_panel', 400, 10_000.0)
      
      # Simulate degradation
      composition = enclosable.operational_data['shell_composition']['solar_cover_panel']
      composition['health_percentage'] = 70.0
      enclosable.save!
    end
    
    it 'improves health percentage' do
      initial_health = enclosable.operational_data.dig('shell_composition', 'solar_cover_panel', 'health_percentage')
      
      result = enclosable.replace_degraded_panels('solar_cover_panel', percentage: 10)
      
      new_health = enclosable.operational_data.dig('shell_composition', 'solar_cover_panel', 'health_percentage')
      expect(new_health).to be > initial_health
    end
    
    it 'calculates panels to replace based on percentage' do
      result = enclosable.replace_degraded_panels('solar_cover_panel', percentage: 10)
      
      # 10% of 400 = 40 panels
      expect(result[:replaced_count]).to eq(40)
    end
    
    it 'returns materials needed' do
      result = enclosable.replace_degraded_panels('solar_cover_panel', percentage: 10)
      
      expect(result[:materials_needed]).to be_a(Hash)
    end
    
    it 'health cannot exceed 100%' do
      composition = enclosable.operational_data['shell_composition']['solar_cover_panel']
      composition['health_percentage'] = 95.0
      enclosable.save!
      
      enclosable.replace_degraded_panels('solar_cover_panel', percentage: 50)
      
      health = enclosable.operational_data.dig('shell_composition', 'solar_cover_panel', 'health_percentage')
      expect(health).to be <= 100.0
      expect(health).to be > 95.0  # Should improve from 95%
    end
  end
  
  describe '#shell_status_report' do
    before do
      enclosable.operational_data = { 'shell_composition' => {} }
      enclosable.update_shell_composition('solar_cover_panel', 300, 7500.0)
      enclosable.update_shell_composition('transparent_cover_panel', 100, 2500.0)
      
      # Add some failures and degradation
      solar_comp = enclosable.operational_data['shell_composition']['solar_cover_panel']
      solar_comp['failed_count'] = 15
      solar_comp['health_percentage'] = 85.0
      enclosable.save!
    end
    
    it 'returns comprehensive status' do
      report = enclosable.shell_status_report
      
      expect(report).to have_key(:total_panels)
      expect(report).to have_key(:total_failed)
      expect(report).to have_key(:average_health)
      expect(report).to have_key(:power_generation)
      expect(report).to have_key(:needs_maintenance)
      expect(report).to have_key(:composition_breakdown)
    end
    
    it 'calculates total panels correctly' do
      report = enclosable.shell_status_report
      
      expect(report[:total_panels]).to eq(400)
    end
    
    it 'calculates total failed correctly' do
      report = enclosable.shell_status_report
      
      expect(report[:total_failed]).to eq(15)
    end
    
    it 'calculates average health' do
      report = enclosable.shell_status_report
      
      # (85 + 100) / 2 = 92.5
      expect(report[:average_health]).to be_within(0.1).of(92.5)
    end
    
    it 'flags maintenance needs when health is low' do
      solar_comp = enclosable.operational_data['shell_composition']['solar_cover_panel']
      solar_comp['health_percentage'] = 75.0
      enclosable.save!
      
      report = enclosable.shell_status_report
      
      expect(report[:needs_maintenance]).to be true
    end
    
    it 'provides breakdown per panel type' do
      report = enclosable.shell_status_report
      
      breakdown = report[:composition_breakdown]
      expect(breakdown).to have_key('solar_cover_panel')
      expect(breakdown).to have_key('transparent_cover_panel')
      
      solar = breakdown['solar_cover_panel']
      expect(solar[:count]).to eq(300)
      expect(solar[:operational]).to eq(285) # 300 - 15 failed
      expect(solar[:status]).to eq('good') # 85% health
    end
  end
  
  describe '#light_transmission' do
    it 'reads from blueprint properties' do
      transmission = enclosable.light_transmission('solar_cover_panel')
      
      expect(transmission).to eq('35%')
    end
    
    it 'returns 0 if not specified' do
      blueprint = blueprint_data.dup
      blueprint['properties'].delete('light_transmission')
      allow(enclosable).to receive(:load_panel_blueprint).and_return(blueprint)
      
      transmission = enclosable.light_transmission('solar_cover_panel')
      
      expect(transmission).to eq(0)
    end
  end
  
  describe '#thermal_rating' do
    it 'reads from blueprint properties' do
      rating = enclosable.thermal_rating('solar_cover_panel')
      
      expect(rating).to eq('R-20')
    end
    
    it 'returns 0 if not specified' do
      blueprint = blueprint_data.dup
      blueprint['properties'].delete('thermal_insulation')
      allow(enclosable).to receive(:load_panel_blueprint).and_return(blueprint)
      
      rating = enclosable.thermal_rating('solar_cover_panel')
      
      expect(rating).to eq(0)
    end
  end
  
  describe 'panel blueprint loading' do
    it 'loads blueprint data flexibly' do
      # Should work with Blueprint model or JSON file
      expect(enclosable).to respond_to(:load_panel_blueprint)
    end
  end
  
  describe 'scale comparison' do
    it 'handles small enclosures (skylight)' do
      small = test_class.create!(worldhouse: worldhouse, segment_index: 3, length_m: 65.0, width_m: 65.0)
      small.diameter = 65
      allow(small).to receive(:load_panel_blueprint).and_return(blueprint_data)
      
      materials = small.calculate_enclosure_materials(panel_type: 'solar_cover_panel')
      
      expect(materials['solar_cover_panel']).to be < 200 # Small number of panels
    end
    
    it 'handles massive enclosures (worldhouse)' do
      massive = test_class.create!(worldhouse: worldhouse, segment_index: 4, length_m: 50_000.0, width_m: 100_000.0)
      massive.width = 100_000
      massive.length = 50_000
      allow(massive).to receive(:load_panel_blueprint).and_return(blueprint_data)
      
      materials = massive.calculate_enclosure_materials(panel_type: 'solar_cover_panel')
      
      expect(materials['solar_cover_panel']).to be > 1_000_000 # Millions of panels
    end
  end
end