# spec/models/modules/base_module_spec.rb
require 'rails_helper'

RSpec.describe Modules::BaseModule, type: :model do
  let(:player) { create(:player) }
  let!(:celestial_body) { create(:large_moon, :luna) }
  let(:location) { 
    create(:celestial_location, 
           name: "Test Location", 
           coordinates: "0.00°N 0.00°E",
           celestial_body: celestial_body) 
  }

  let(:test_craft) do
    craft = create(:base_craft, owner: player)
    craft.celestial_location = location
    craft.save!
    craft
  end
  
  let(:settlement) { create(:base_settlement, owner: player) }
  let(:test_structure) { create(:base_structure, settlement: settlement, owner: player) }

  # ✅ NO MOCKS - Use real lookup service with real data files

  describe 'associations' do
    it { should belong_to(:attachable).optional }
    
    it 'accepts craft as polymorphic attachable' do
      module_obj = build(:base_module, attachable: test_craft)
      expect(module_obj.attachable).to eq(test_craft)
      expect(module_obj.attachable_type).to eq('Craft::BaseCraft')
    end
    
    it 'accepts structure as polymorphic attachable' do
      module_obj = build(:base_module, attachable: test_structure)
      expect(module_obj.attachable).to eq(test_structure)
      expect(module_obj.attachable_type).to eq('Structures::BaseStructure')
    end
    
    it 'can be created without attachable' do
      module_obj = build(:base_module, attachable: nil)
      expect(module_obj.attachable).to be_nil
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:module_type) }
    it { should validate_presence_of(:identifier) }
    
    it 'creates valid module with all required fields' do
      module_obj = build(:base_module, 
        name: 'Test Module',
        module_type: 'life_support',
        identifier: 'test_001'
      )
      expect(module_obj).to be_valid
    end
  end

  describe 'callbacks' do
    describe 'before_validation :load_module_data on create' do
      context 'when module data is found' do
        it 'loads CO2 scrubber data from lookup service' do
          # ✅ FIX: Use the :from_lookup trait instead of manual nil setting
          module_obj = build(:base_module, :from_lookup,
            module_type: 'co2_scrubber',
            identifier: 'test_co2_scrubber'
          )
          module_obj.valid? # Trigger validation callbacks
          
          expect(module_obj.name).to eq('CO2 Scrubber Module')
          expect(module_obj.description).to eq('Removes CO2 from atmosphere')
          expect(module_obj.energy_cost).to eq(5.0)
          expect(module_obj.operational_data).to be_present
          expect(module_obj.operational_data['name']).to eq('CO2 Scrubber Module')
        end

        it 'does not override existing name if already set' do
          # ✅ Use regular factory with pre-set name to test ||= behavior
          module_obj = build(:base_module, 
            name: 'Custom Name',  # This should be preserved
            module_type: 'co2_scrubber',
            identifier: 'test_custom'
          )
          module_obj.valid?
          
          expect(module_obj.name).to eq('Custom Name')
          # Factory values should be preserved due to ||= logic
          expect(module_obj.description).to eq('Test module description')
          expect(module_obj.energy_cost).to eq(10)
        end
      end

      context 'when module data is not found' do
        it 'does not crash when module type doesnt exist' do
          module_obj = build(:base_module, 
            name: 'Test Module',
            module_type: 'unknown_module',
            identifier: 'test_001'
          )
          
          expect { module_obj.valid? }.not_to raise_error
          # ✅ FIX: Accept either nil or empty hash
          expect(module_obj.operational_data).to be_nil.or be_empty
        end
      end
    end

    describe 'after_create :apply_module_to_attachable' do
      it 'applies module to craft when created with craft attachable' do
        # Mock the craft's add_module_effect method
        expect(test_craft).to receive(:add_module_effect).with(instance_of(Modules::BaseModule))
        
        create(:base_module, attachable: test_craft)
      end

      it 'applies module to structure when created with structure attachable' do
        # Mock the structure's add_module_effect method
        expect(test_structure).to receive(:add_module_effect).with(instance_of(Modules::BaseModule))
        
        create(:base_module, attachable: test_structure)
      end

      it 'does not crash when created without attachable' do
        expect { create(:base_module) }.not_to raise_error
      end
    end

    describe 'before_destroy :remove_module_from_attachable' do
      it 'removes module from craft when destroyed' do
        module_obj = create(:base_module, attachable: test_craft)
        
        expect(test_craft).to receive(:remove_module_effect).with(module_obj)
        
        module_obj.destroy
      end

      it 'removes module from structure when destroyed' do
        module_obj = create(:base_module, attachable: test_structure)
        
        expect(test_structure).to receive(:remove_module_effect).with(module_obj)
        
        module_obj.destroy
      end

      it 'does not crash when destroyed without attachable' do
        module_obj = create(:base_module)
        
        expect { module_obj.destroy }.not_to raise_error
      end
    end
  end

  describe 'instance methods' do
    let(:co2_scrubber_module) do
      # ✅ FIX: Use :from_lookup trait to get real lookup service data
      create(:base_module, :from_lookup, module_type: 'co2_scrubber')
    end

    describe '#operational_status' do
      it 'returns operational status from loaded data' do
        expect(co2_scrubber_module.operational_status).to eq('active')
      end

      it 'returns inactive when operational_data is missing' do
        co2_scrubber_module.operational_data = nil
        expect(co2_scrubber_module.operational_status).to eq('inactive')
      end
    end

    describe '#input_resources' do
      it 'returns input resources from loaded data' do
        resources = co2_scrubber_module.input_resources
        
        expect(resources).to be_an(Array)
        expect(resources.first['id']).to eq('air')
        expect(resources.first['amount']).to eq(100)
      end

      it 'returns empty array when operational_data is missing' do
        co2_scrubber_module.operational_data = nil
        expect(co2_scrubber_module.input_resources).to eq([])
      end
    end

    describe '#output_resources' do
      it 'returns output resources from loaded data' do
        resources = co2_scrubber_module.output_resources
        
        expect(resources).to be_an(Array)
        expect(resources.first['id']).to eq('stored_co2')
        expect(resources.first['amount']).to eq(2.5)
      end
    end

    describe '#consumables' do
      it 'returns consumables from loaded data' do
        consumables = co2_scrubber_module.consumables
        
        expect(consumables).to be_a(Hash)
        expect(consumables['energy']).to eq(5.0)
      end
    end
  end

  describe 'AtmosphericProcessing integration' do
    # ✅ FIX: Use :from_lookup for real lookup service data
    let(:co2_scrubber_module) { create(:base_module, :from_lookup, module_type: 'co2_scrubber') }
    let(:life_support_module) { create(:base_module, :from_lookup, module_type: 'life_support') }

    describe '#can_process_atmosphere?' do
      it 'returns true for CO2 scrubber module' do
        expect(co2_scrubber_module.can_process_atmosphere?).to be true
      end

      it 'returns false for basic life support module' do
        expect(life_support_module.can_process_atmosphere?).to be false
      end
    end

    describe '#atmospheric_capabilities' do
      it 'identifies CO2 scrubbing capability' do
        capabilities = co2_scrubber_module.atmospheric_capabilities
        
        expect(capabilities[:co2_scrubbing]).to be true
        expect(capabilities[:air_filtration]).to be false
      end
    end

    describe '#max_processing_rate' do
      it 'returns correct rates for CO2 scrubber' do
        expect(co2_scrubber_module.max_processing_rate('air')).to eq(100)
        expect(co2_scrubber_module.max_processing_rate('stored_co2')).to eq(2.5)
        expect(co2_scrubber_module.max_processing_rate('unknown')).to eq(0)
      end
    end
  end

  describe 'factory integration' do
    it 'creates valid module using existing factory' do
      module_obj = create(:base_module)
      
      expect(module_obj).to be_persisted
      expect(module_obj).to be_valid
      expect(module_obj.name).to be_present
      expect(module_obj.module_type).to eq('life_support')
    end

    it 'creates CO2 scrubber with trait' do
      module_obj = create(:base_module, :co2_scrubber)
      
      expect(module_obj.name).to eq('CO2 Scrubber Module')
      expect(module_obj.module_type).to eq('co2_scrubber')
      expect(module_obj.energy_cost).to eq(15) # From factory trait
    end
  end

  describe 'error handling' do
    it 'handles missing operational_data gracefully' do
      module_obj = create(:base_module)
      module_obj.operational_data = nil
      module_obj.save!
      
      expect(module_obj.operational_status).to eq('inactive')
      expect(module_obj.input_resources).to eq([])
      expect(module_obj.output_resources).to eq([])
      expect(module_obj.consumables).to eq({})
    end
    
    it 'handles empty operational_data gracefully' do
      module_obj = create(:base_module)
      module_obj.operational_data = {}
      module_obj.save!
      
      expect(module_obj.operational_status).to eq('inactive')
      expect(module_obj.input_resources).to eq([])
      expect(module_obj.output_resources).to eq([])
      expect(module_obj.consumables).to eq({})
    end
  end
end