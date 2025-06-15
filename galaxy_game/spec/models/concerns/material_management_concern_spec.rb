require 'rails_helper'

RSpec.describe MaterialManagementConcern, type: :concern do
  # Create a test class that includes the concern
  let(:test_class) do
    Class.new do
      include ActiveModel::Model
      include MaterialManagementConcern
      
      attr_accessor :materials, :atmosphere
      
      def initialize
        @materials = nil  # Will be set up in tests
        @atmosphere = nil
      end
    end
  end
  
  let(:test_object) { test_class.new }
  
  # ✅ Set up the materials association mock outside the class
  let(:mock_materials_association) { double('materials_association') }
  
  before do
    # ✅ Assign the mock after object creation
    test_object.materials = mock_materials_association
  end

  describe '#add_material' do
    # ✅ Fixed: Add ALL methods the concern calls on material objects
    let(:mock_material) { 
      double('Material', 
        amount: 0, 
        'amount=': nil, 
        'save!': true,
        'new_record?': true,
        'name=': nil,
        name: 'oxygen'  # ✅ Add name getter for debug logging
      ) 
    }
    
    before do
      allow(mock_materials_association).to receive(:find_or_initialize_by).and_return(mock_material)
    end

    context 'with valid inputs' do
      # ✅ NO MOCKING of MaterialLookupService - use real service with fixtures
      
      it 'validates positive amount' do
        expect {
          test_object.add_material('oxygen', -10)
        }.to raise_error(MaterialManagementConcern::InvalidMaterialError, "Invalid amount value")
      end

      it 'validates material name presence' do
        expect {
          test_object.add_material('', 100)
        }.to raise_error(MaterialManagementConcern::InvalidMaterialError, "Material name required")
      end

      it 'looks up material data using real service' do
        # ✅ This will use the real MaterialLookupService and oxygen.json fixture
        test_object.add_material('oxygen', 100)
        # If this passes, the real lookup worked
      end

      it 'raises error for unknown material' do
        expect {
          test_object.add_material('unobtainium', 100)
        }.to raise_error(MaterialManagementConcern::InvalidMaterialError, /not found in materials database/)
      end

      it 'creates material with standardized ID' do
        expect(mock_materials_association).to receive(:find_or_initialize_by).with(name: 'oxygen')
        expect(mock_material).to receive(:amount=).with(100)
        expect(mock_material).to receive(:name=).with('oxygen')
        expect(mock_material).to receive(:save!)
        
        result = test_object.add_material('oxygen', 100)
        expect(result).to eq(mock_material)
      end

      it 'adds to existing material amount' do
        # ✅ For existing materials, new_record? should return false
        allow(mock_material).to receive(:new_record?).and_return(false)
        allow(mock_material).to receive(:amount).and_return(50)
        expect(mock_material).to receive(:amount=).with(150)
        expect(mock_material).not_to receive(:name=)
        
        test_object.add_material('oxygen', 100)
      end
    end

    context 'when material is a gas' do
      let(:mock_atmosphere) { double('Atmosphere') }
      
      before do
        allow(test_object).to receive(:has_gas_properties?).with('oxygen').and_return(true)
        allow(test_object).to receive(:update_atmosphere_for_gas)
        test_object.atmosphere = mock_atmosphere
      end

      it 'updates atmosphere composition' do
        expect(test_object).to receive(:update_atmosphere_for_gas).with('O2', 100)
        
        test_object.add_material('oxygen', 100)
      end
    end
  end

  describe '#remove_material' do
    let(:mock_material) { 
      double('Material', 
        amount: 150, 
        'amount=': nil, 
        'save!': true, 
        destroy: true,
        name: 'iron'
      ) 
    }
    
    before do
      allow(mock_materials_association).to receive(:find_by).and_return(mock_material)
    end

    context 'with valid inputs' do
      it 'validates positive amount' do
        expect {
          test_object.remove_material('iron', -10)
        }.to raise_error(MaterialManagementConcern::InvalidMaterialError, "Invalid amount value")
      end

      it 'validates material name presence' do
        expect {
          test_object.remove_material('', 100)
        }.to raise_error(MaterialManagementConcern::InvalidMaterialError, "Material name required")
      end

      it 'raises error for unknown material' do
        expect {
          test_object.remove_material('unobtainium', 100)
        }.to raise_error(MaterialManagementConcern::InvalidMaterialError, /not found in materials database/)
      end

      it 'raises error for insufficient material' do
        allow(mock_material).to receive(:amount).and_return(50)
        
        expect {
          test_object.remove_material('iron', 100)
        }.to raise_error(MaterialManagementConcern::InsufficientMaterialError, "Not enough iron available")
      end

      it 'raises error when material not found' do
        allow(mock_materials_association).to receive(:find_by).and_return(nil)
        
        expect {
          test_object.remove_material('iron', 100)
        }.to raise_error(MaterialManagementConcern::InsufficientMaterialError, "Not enough iron available")
      end

      it 'reduces material amount and saves' do
        expect(mock_material).to receive(:amount=).with(50)  # 150 - 100
        expect(mock_material).to receive(:save!)
        
        result = test_object.remove_material('iron', 100)
        expect(result).to be true
      end

      # ✅ Fix 1: Material is saved with amount=0, not destroyed
      it 'sets amount to zero when fully removed' do
        allow(mock_material).to receive(:amount).and_return(100)
        expect(mock_material).to receive(:amount=).with(0)
        expect(mock_material).to receive(:save!)  # ✅ Changed from destroy to save!
        
        test_object.remove_material('iron', 100)
      end
    end

    context 'when material is a gas' do
      let(:mock_atmosphere) { double('Atmosphere') }
      
      before do
        allow(test_object).to receive(:has_gas_properties?).with('iron').and_return(true)
        allow(test_object).to receive(:update_atmosphere_for_gas)
        test_object.atmosphere = mock_atmosphere
      end

      # ✅ Fix 2: Iron has chemical_formula "Fe" in the fixture
      it 'updates atmosphere composition' do
        expect(test_object).to receive(:update_atmosphere_for_gas).with("Fe", -100)  # ✅ Changed from nil to "Fe"
        
        test_object.remove_material('iron', 100)
      end
    end
  end

  describe '#has_gas_properties?' do
    # ✅ NO MOCKING - use real MaterialLookupService
    
    it 'returns true for gases' do
      # Uses real service with oxygen.json fixture
      expect(test_object.send(:has_gas_properties?, 'oxygen')).to be true
    end

    it 'returns false for non-gas materials' do
      # This will fail if iron.json doesn't exist, which is expected
      expect(test_object.send(:has_gas_properties?, 'iron')).to be_falsy
    end

    it 'returns falsy when material not found' do
      expect(test_object.send(:has_gas_properties?, 'unobtainium')).to be_falsy
    end
  end

  # ✅ Real integration tests using actual CelestialBody
  describe 'integration with CelestialBody' do
    let(:star) { create(:star) }
    let(:solar_system) { create(:solar_system, current_star: star) }
    let(:mars) { create(:terrestrial_planet, :mars, solar_system: solar_system) }
    
    # ✅ NO MOCKING - Use real MaterialLookupService with fixtures
    
    it 'works with actual celestial body materials association' do
      expect {
        mars.add_material('oxygen', 100)
      }.to change { mars.materials.count }.by(1)
      
      material = mars.materials.last
      expect(material.name).to eq('oxygen')
      expect(material.amount).to eq(100)
    end
    
    it 'handles material validation errors properly' do
      expect {
        mars.add_material('unobtainium', 100)
      }.to raise_error(MaterialManagementConcern::InvalidMaterialError, /not found in materials database/)
    end
    
    it 'correctly identifies gas materials from fixtures' do
      # ✅ This should now return true with the fixed method
      expect(mars.send(:has_gas_properties?, 'oxygen')).to be true
    end
  end
end