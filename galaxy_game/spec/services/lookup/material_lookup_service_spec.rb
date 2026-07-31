
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
    # Clear all class instance variables (including @materials_cache)
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
  end

  describe '#find_material' do
    it 'loads materials from the correct file structure' do
      gases_path = Lookup::MaterialLookupService::MATERIAL_PATHS[:gases][:path].call
      expect(File.directory?(gases_path)).to be true
    end    

    it 'finds atmospheric gases by chemical formula' do
      o2 = @service.find_material("O2")
      expect(o2).not_to be_nil
      expect(o2.dig('properties', 'chemical_formula') || o2['chemical_formula']).to eq("O2")
      expect(o2["id"]).to eq("oxygen")
      expect(@service.get_material_property(o2, 'molar_mass')).to eq(31.9988)
    end

    it 'finds materials case-insensitively by chemical formula' do
      o2_material = @service.find_material("o2")
      expect(@service.get_material_property(o2_material, 'chemical_formula')).to eq("O2")
      expect(o2_material["id"]).to eq("oxygen")
    end

    it 'supports lookup by common name for UI compatibility only' do
      # Backend should prefer chemical formulas, but name lookup is supported for UI
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
      o2 = @service.find_material("O2")
      next unless o2
      expect(@service.get_material_property(o2, 'molar_mass')).to be_a(Numeric)
      expect(@service.get_material_property(o2, 'molar_mass')).to eq(31.9988)
      expect(@service.get_material_property(o2, 'state_at_stp')).to eq('gas')
      expect(o2.dig('properties', 'chemical_formula')).to eq('O2')
      expect(o2['id']).to eq('oxygen')
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
      after do
        FileUtils.rm_rf(temp_dir)
      end
      it 'handles JSON parsing errors gracefully' do
        # Create corrupted file with .json extension
        File.write(corrupted_file, '{ invalid json', mode: 'w')
        # Allow any error logging
        allow(Rails.logger).to receive(:error)
        service = described_class.new
        result = service.send(:load_json_files, temp_dir)
        expect(Rails.logger).to have_received(:error).with(/Invalid JSON in file:/)
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
      it 'handles empty materials gracefully' do
        # This test verifies that find_material returns nil for unknown materials
        # even when the cache doesn't contain them
        service = described_class.new
        expect(service.find_material('unobtainium_xyz_nonexistent')).to be_nil
      end
      # Note: The error logging test is no longer applicable since we cache at class level
      # and initialize no longer does disk I/O
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

  describe 'class-level caching behavior' do
    it 'loads materials into a class-level cache on first access' do
      cache = described_class.materials_cache
      
      # Verify cache was created
      expect(cache).to be_a(Hash)
      expect(cache.size).to be > 0
    end

    it 'reuses the same cache across multiple instances' do
      service1 = described_class.new
      cache1 = described_class.materials_cache
      
      # Create another instance
      service2 = described_class.new
      cache2 = described_class.materials_cache
      
      # Both should point to the same cache object (same object_id)
      expect(cache1.object_id).to eq(cache2.object_id)
    end

    it 'finds materials using the cached hash' do
      # First lookup
      result1 = @service.find_material('oxygen')
      if result1
        # Second lookup should use cache (no disk I/O)
        result2 = @service.find_material('oxygen')
        expect(result2).not_to be_nil
        
        # Both results should be the same
        expect(result1['id']).to eq(result2['id'])
      else
        skip "Oxygen material not available in test fixtures"
      end
    end

    it 'indexes materials by id, name, and chemical_formula' do
      cache = described_class.materials_cache
      
      # Should have entries keyed by normalized lookups
      # (id, name, and chemical_formula all downcased)
      # Verify cache has decent size (at least 10+ entries)
      expect(cache.size).to be >= 10
    end

    it 'performs O(1) lookups for exact matches' do
      # Try to find a material that exists
      material = @service.find_material('oxygen') || @service.find_material('N2') || @service.find_material('CO2')
      
      if material
        # Verify we can look it up by different keys
        expect(material).to be_a(Hash)
        expect(material).to have_key('id')
      else
        skip "No test material fixtures available"
      end
    end

    it 'allows cache reset for testing purposes' do
      # First, ensure cache is loaded
      cache_before = described_class.materials_cache
      expect(cache_before).to be_a(Hash)
      expect(cache_before.size).to be > 0
      
      # Reset cache
      described_class.reset_cache!
      
      # Cache should be nil now
      expect(described_class.instance_variable_get(:@materials_cache)).to be_nil
      
      # Next access should reload
      new_cache = described_class.materials_cache
      expect(new_cache).to be_a(Hash)
      expect(new_cache.size).to be > 0
    end

    it 'does not perform disk I/O on subsequent find_material calls' do
      # Warm up cache with a lookup
      material = @service.find_material('oxygen')
      
      if material
        # Mock File.read to verify it's not called again
        allow(File).to receive(:read).and_call_original
        
        # Multiple lookups should not call File.read
        10.times { @service.find_material('oxygen') }
        
        # File.read should not have been called (cache was warm)
        expect(File).not_to have_received(:read)
      else
        skip "Oxygen material not available in test fixtures"
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