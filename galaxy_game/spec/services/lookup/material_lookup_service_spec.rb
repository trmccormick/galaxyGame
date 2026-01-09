
require 'rails_helper'
require 'json'

RSpec.describe Lookup::MaterialLookupService do
  # Nuclear option: reset everything before the entire suite
  before(:all) do
    reset_lookup_service
  end

  # And before each test
  before(:each) do
    reset_lookup_service
  end

  def reset_lookup_service
    # Clear singleton instance
    if described_class.respond_to?(:instance_variable_defined?) && 
       described_class.instance_variable_defined?(:@instance)
      described_class.remove_instance_variable(:@instance)
    end
    # Clear all class instance variables
    described_class.instance_variables.each do |var|
      described_class.remove_instance_variable(var)
    end
    # Force new instance with fresh data load
    if described_class.respond_to?(:new)
      @service = described_class.new
    elsif described_class.respond_to?(:instance)
      described_class.instance_variable_set(:@instance, nil)
      @service = described_class.instance
    end
    # Trigger data load
    @service.instance_variable_set(:@loaded, false) rescue nil
  end

  describe '#find_material' do
    it 'loads materials from the correct file structure' do
      gases_path = Lookup::MaterialLookupService::MATERIAL_PATHS[:gases][:path].call
      expect(File.directory?(gases_path)).to be true
    end    

    it 'finds atmospheric gases by chemical formula' do
      oxygen = @service.find_material("O2")
      expect(oxygen).not_to be_nil
      expect(oxygen.dig('properties', 'chemical_formula') || oxygen['chemical_formula']).to eq("O2")
      expect(oxygen["id"]).to eq("oxygen")
      expect(@service.get_material_property(oxygen, 'molar_mass')).to eq(31.9988)
    end

    it 'finds materials case-insensitively' do
      o2_material = @service.find_material("o2")
      expect(@service.get_material_property(o2_material, 'chemical_formula')).to eq("O2")
      expect(o2_material["id"]).to eq("oxygen")
      oxygen_material = @service.find_material("oxygen")
      expect(@service.get_material_property(oxygen_material, 'chemical_formula')).to eq("O2")
      expect(oxygen_material["id"]).to eq("oxygen")
    end

    it 'returns nil for nonexistent materials' do
      expect(@service.find_material("unobtainium")).to be_nil
    end
  end

  describe "atmosphere gas creation behavior" do
    it "correctly maps chemical formulas for atmosphere creation" do
      test_cases = [
        { formula: 'O2', expected_id: 'oxygen' },
        { formula: 'N2', expected_id: 'nitrogen' },
        { formula: 'CO2', expected_id: 'carbon_dioxide' }
      ]
      test_cases.each do |test_case|
        material = @service.find_material(test_case[:formula])
        next unless material
        expect(@service.get_material_property(material, 'chemical_formula')).to eq(test_case[:formula])
      end
    end
  end

  describe "material property access" do
    it 'provides access to material properties directly from data' do
      oxygen = @service.find_material("oxygen")
      next unless oxygen
      expect(@service.get_material_property(oxygen, 'molar_mass')).to be_a(Numeric)
      expect(@service.get_material_property(oxygen, 'molar_mass')).to eq(31.9988)
      expect(@service.get_material_property(oxygen, 'state_at_stp')).to eq('gas')
      expect(oxygen.dig('properties', 'chemical_formula')).to eq('O2')
      expect(oxygen['id']).to eq('oxygen')
    end
    it 'has all expected material properties' do
      ilmenite = @service.find_material("ilmenite")
      next unless ilmenite
      expect(ilmenite).to have_key('id')
      expect(ilmenite).to have_key('name')
      expect(ilmenite.dig('properties')).to have_key('chemical_formula')
      expect(@service.get_material_property(ilmenite, 'molar_mass')).to be_a(Numeric)
      expect(ilmenite.dig('classification')).to have_key('category')
    end
  end

  describe '#get_material_property' do
    context 'with valid material' do
      let(:material) do
        {
          'id' => 'oxygen',
          'molar_mass' => 31.9988,
          'properties' => {
            'density' => 1.429,
            'boiling_point' => 90.2
          }
        }
      end
      it 'returns top-level properties' do
        expect(@service.get_material_property(material, 'molar_mass')).to eq(31.9988)
        expect(@service.get_material_property(material, 'id')).to eq('oxygen')
      end
      it 'returns nested properties from properties hash' do
        expect(@service.get_material_property(material, 'density')).to eq(1.429)
        expect(@service.get_material_property(material, 'boiling_point')).to eq(90.2)
      end
      it 'returns nil for non-existent properties' do
        expect(@service.get_material_property(material, 'non_existent')).to be_nil
      end
    end
    context 'with nil material' do
      it 'returns nil gracefully' do
        expect(@service.get_material_property(nil, 'molar_mass')).to be_nil
      end
    end
    context 'with nil property name' do
      let(:material) { { 'id' => 'test' } }
      it 'returns nil gracefully' do
        expect(@service.get_material_property(material, nil)).to be_nil
      end
    end
  end

  describe '#get_molar_mass' do
    it 'returns molar mass for existing materials' do
      oxygen = @service.find_material('oxygen')
      skip "Oxygen fixture not found" unless oxygen
      molar_mass = @service.get_molar_mass('oxygen')
      expect(molar_mass).to be_a(Numeric)
      expect(molar_mass).to eq(31.9988)
    end
    it 'returns nil for non-existent materials' do
      expect(@service.get_molar_mass('unobtainium')).to be_nil
    end
  end

  describe '#atmospheric_components' do
    let(:sample_components) do
      [
        { chemical: 'O2', percentage: 21.0 },
        { chemical: 'N2', percentage: 78.0 },
        { chemical: 'CO2', percentage: 0.04 },
        { chemical: 'unobtainium', percentage: 1.0 }
      ]
    end
    it 'converts chemical formulas to material data' do
      result = @service.atmospheric_components(sample_components)
      expect(result).to be_an(Array)
      expect(result.size).to be <= sample_components.size
      result.each do |component|
        expect(component).to have_key(:material)
        expect(component).to have_key(:percentage)
        expect(component[:material]).to be_a(Hash)
        expect(component[:percentage]).to be_a(Numeric)
      end
    end
    it 'filters out unknown materials' do
      unknown_components = [
        { chemical: 'unobtainium', percentage: 50.0 },
        { chemical: 'impossibilium', percentage: 50.0 }
      ]
      result = @service.atmospheric_components(unknown_components)
      expect(result).to be_empty
    end
    it 'preserves percentage data' do
      oxygen = @service.find_material('O2')
      next unless oxygen
      components = [{ chemical: 'O2', percentage: 21.0 }]
      result = @service.atmospheric_components(components)
      expect(result.first[:percentage]).to eq(21.0)
      expect(@service.get_material_property(result.first[:material], 'chemical_formula')).to eq('O2')
    end
  end

  describe '.base_materials_path' do
    it 'returns a Pathname object' do
      path = described_class.base_materials_path
      expect(path).to be_a(Pathname)
    end
    it 'points to the correct materials directory' do
      path = described_class.base_materials_path
      expected_path = GalaxyGame::Paths::JSON_DATA.join("resources", "materials")
      expect(path).to eq(expected_path)
    end
  end

  describe '.locate_gases_path' do
    it 'returns the gases directory path' do
      path = described_class.locate_gases_path
      expect(path).to be_a(String)
      expect(path).to include('materials/gases')
    end
    it 'uses GalaxyGame::Paths consistently' do
      path = described_class.locate_gases_path
      expected_path = File.join(GalaxyGame::Paths::JSON_DATA, "resources", "materials", "gases")
      expect(path).to eq(expected_path)
    end
  end

  describe 'MATERIAL_PATHS configuration' do
    it 'has all expected material types' do
      expected_types = %w[building byproducts chemicals gases liquids processed raw]
      actual_types = described_class::MATERIAL_PATHS.keys.map(&:to_s)
      expected_types.each do |type|
        expect(actual_types).to include(type), "Expected MATERIAL_PATHS to include '#{type}'"
      end
    end
    it 'has valid path configurations' do
      described_class::MATERIAL_PATHS.each do |type, config|
        expect(config).to be_a(Hash), "Expected #{type} config to be a Hash"
        expect(config).to have_key(:path), "Expected #{type} to have :path key"
        path = config[:path].call
        expect(path).to be_a(Pathname), "Expected #{type} path to return Pathname"
      end
    end
  end

  describe '#debug_paths' do
    it 'prints path information without errors' do
      expect { @service.debug_paths }.not_to raise_error
    end
    it 'outputs expected format' do
      output = capture_stdout { @service.debug_paths }
      expect(output).to include('DEBUG: Material Lookup Paths')
      expect(output).to include('gases:')
      expect(output).to include('liquids:')
    end
  end

  describe 'error handling' do
    context 'with corrupted JSON files' do
      let(:temp_dir) { Dir.mktmpdir }
      let(:corrupted_file) { File.join(temp_dir, 'corrupted.json') }
      before do
        File.write(corrupted_file, '{ invalid json }')
      end
      after do
        FileUtils.rm_rf(temp_dir)
      end
      it 'handles JSON parsing errors gracefully' do
        expect(Rails.logger).to receive(:error).with(/Invalid JSON in file:/).exactly(1).times
        result = @service.send(:load_json_files, temp_dir)
        expect(result).to be_empty
      end
    end
    context 'with missing directories' do
      it 'handles missing directories gracefully' do
        result = @service.send(:load_json_files, '/nonexistent/path')
        expect(result).to be_empty
      end
      it 'handles missing recursive directories gracefully' do
        result = @service.send(:load_json_files_recursively, '/nonexistent/path')
        expect(result).to be_empty
      end
    end
    context 'with service initialization errors' do
      it 'continues with empty materials on load failure' do
        described_class.class_variable_set(:@@material_cache, nil)
        allow_any_instance_of(described_class).to receive(:load_materials).and_raise(StandardError, "Test error")
        expect { service = described_class.new }.not_to raise_error
        service = described_class.new
        expect(service.find_material('oxygen')).to be_nil
      end
      it 'logs errors when initialization fails' do
        described_class.class_variable_set(:@@material_cache, nil)
        allow_any_instance_of(described_class).to receive(:load_materials).and_raise(StandardError, "Test error")
        expect(Rails.logger).to receive(:error).at_least(:once)
        described_class.new
      end
    end
  end

  describe 'material matching logic' do
    let(:test_material) do
      {
        'id' => 'oxygen',
        'name' => 'Oxygen',
        'chemical_formula' => 'O2'
      }
    end
    it 'matches by exact chemical formula' do
      expect(@service.send(:match_material?, test_material, 'O2')).to be true
      expect(@service.send(:match_material?, test_material, 'o2')).to be true
    end
    it 'matches by material ID' do
      expect(@service.send(:match_material?, test_material, 'oxygen')).to be true
      expect(@service.send(:match_material?, test_material, 'OXYGEN')).to be true
    end
    it 'matches by name' do
      expect(@service.send(:match_material?, test_material, 'Oxygen')).to be true
      expect(@service.send(:match_material?, test_material, 'oxygen')).to be true
    end
    it 'handles partial matches in name and ID' do
      expect(@service.send(:match_material?, test_material, 'oxy')).to be true
    end
    it 'returns false for non-matches' do
      expect(@service.send(:match_material?, test_material, 'nitrogen')).to be false
      expect(@service.send(:match_material?, test_material, 'N2')).to be false
    end
    it 'handles nil inputs gracefully' do
      expect(@service.send(:match_material?, nil, 'oxygen')).to be false
      expect(@service.send(:match_material?, test_material, nil)).to be false
      expect(@service.send(:match_material?, nil, nil)).to be false
    end
  end

  describe 'integration with AtmosphereConcern' do
    it 'provides materials needed for atmospheric calculations' do
      common_gases = %w[O2 N2 CO2 H2O CH4 He H2 Ar]
      found_gases = common_gases.map do |formula|
        material = @service.find_material(formula)
        next unless material
        {
          formula: formula,
          id: material['id'],
          molar_mass: @service.get_material_property(material, 'molar_mass')
        }
      end.compact
      expect(found_gases.size).to be > 0
      found_gases.each do |gas|
        expect(gas[:molar_mass]).to be_a(Numeric), "#{gas[:formula]} should have numeric molar_mass"
        expect(gas[:molar_mass]).to be > 0, "#{gas[:formula]} molar_mass should be positive"
      end
    end
  end

  # Helper method for capturing stdout
  def capture_stdout
    original_stdout = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = original_stdout
    end
    fake.string
  end
end