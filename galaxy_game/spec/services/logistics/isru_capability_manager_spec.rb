
require 'rails_helper'

describe Logistics::ISRUCapabilityManager do
  # Create mock unit objects with unit_name
  let(:o2_unit) { double('Unit', unit_name: 'planetary_volatiles_extractor_mk1') }
  let(:power_unit) { double('Unit', unit_name: 'solar_panel') }
  let(:other_unit) { double('Unit', unit_name: 'habitat_module') }

  describe '.assess_isru_capability' do
    it 'returns viable true when both O2 extraction and power equipment exist' do
      settlement = double('Settlement', base_units: [o2_unit, power_unit], operational_data: {})
      
      result = described_class.assess_isru_capability(settlement)
      
      expect(result[:viable]).to be true
      expect(result[:o2_extraction]).to be true
      expect(result[:power_source]).to be true
      expect(result[:missing]).to be_empty
    end

    it 'returns viable false when O2 extraction equipment is missing' do
      settlement = double('Settlement', base_units: [power_unit], operational_data: {})
      
      result = described_class.assess_isru_capability(settlement)
      
      expect(result[:viable]).to be false
      expect(result[:o2_extraction]).to be false
      expect(result[:power_source]).to be true
      expect(result[:missing]).to include(*Logistics::ISRUCapabilityManager::O2_EQUIPMENT_NAMES)
    end

    it 'returns viable false when power equipment is missing' do
      settlement = double('Settlement', base_units: [o2_unit], operational_data: {})
      
      result = described_class.assess_isru_capability(settlement)
      
      expect(result[:viable]).to be false
      expect(result[:o2_extraction]).to be true
      expect(result[:power_source]).to be false
      expect(result[:missing]).to include(*Logistics::ISRUCapabilityManager::POWER_EQUIPMENT_NAMES)
    end

    it 'returns both missing equipment types when neither exists' do
      settlement = double('Settlement', base_units: [other_unit], operational_data: {})
      
      result = described_class.assess_isru_capability(settlement)
      
      expect(result[:viable]).to be false
      expect(result[:o2_extraction]).to be false
      expect(result[:power_source]).to be false
      expect(result[:missing]).to include(*Logistics::ISRUCapabilityManager::O2_EQUIPMENT_NAMES)
      expect(result[:missing]).to include(*Logistics::ISRUCapabilityManager::POWER_EQUIPMENT_NAMES)
    end

    it 'returns viable false when base_units is empty' do
      settlement = double('Settlement', base_units: [], operational_data: {})
      
      result = described_class.assess_isru_capability(settlement)
      
      expect(result[:viable]).to be false
      expect(result[:missing]).to include(*Logistics::ISRUCapabilityManager::O2_EQUIPMENT_NAMES)
      expect(result[:missing]).to include(*Logistics::ISRUCapabilityManager::POWER_EQUIPMENT_NAMES)
    end

    it 'recognizes all O2 equipment variants' do
      o2_variants = [
        'planetary_volatiles_extractor_mk1',
        'planetary_volatiles_extractor_mk2',
        'co2_oxygen_production_unit',
        'thermal_extraction_unit',
        'lunar_oxygen_extractor'
      ]
      
      o2_variants.each do |equipment_name|
      unit = double('Unit', unit_name: equipment_name)
      settlement = double('Settlement', base_units: [unit, power_unit], operational_data: {})
        
        result = described_class.assess_isru_capability(settlement)
        
        expect(result[:o2_extraction]).to be(true), "Expected #{equipment_name} to be recognized as O2 equipment"
      end
    end

    it 'recognizes all power equipment variants' do
      power_variants = [
        'solar_panel',
        'nuclear_reactor',
        'radioisotope_thermoelectric_generator',
        'rtg',
        'biogas_generator_engine'
      ]
      
      power_variants.each do |equipment_name|
      unit = double('Unit', unit_name: equipment_name)
      settlement = double('Settlement', base_units: [o2_unit, unit], operational_data: {})
        
        result = described_class.assess_isru_capability(settlement)
        
        expect(result[:power_source]).to be(true), "Expected #{equipment_name} to be recognized as power equipment"
      end
    end
  end

  describe '.has_basic_isru?' do
    it 'returns true when settlement is viable' do
      settlement = double('Settlement', base_units: [o2_unit, power_unit], operational_data: {})
      expect(described_class.has_basic_isru?(settlement)).to be true
    end

    it 'returns false when settlement is not viable' do
      settlement = double('Settlement', base_units: [other_unit], operational_data: {})
      expect(described_class.has_basic_isru?(settlement)).to be false
    end

    it 'returns false when base_units is empty' do
      settlement = double('Settlement', base_units: [], operational_data: {})
      expect(described_class.has_basic_isru?(settlement)).to be false
    end
  end

  describe '.missing_for_survival' do
    it 'returns empty array when both equipment types present' do
      settlement = double('Settlement', base_units: [o2_unit, power_unit], operational_data: {})
      missing = described_class.missing_for_survival(settlement)
      expect(missing).to be_empty
    end

    it 'returns all O2 equipment names when O2 is missing' do
      settlement = double('Settlement', base_units: [power_unit], operational_data: {})
      missing = described_class.missing_for_survival(settlement)
      
      expect(missing).to include(*Logistics::ISRUCapabilityManager::O2_EQUIPMENT_NAMES)
      expect(missing).not_to include(*Logistics::ISRUCapabilityManager::POWER_EQUIPMENT_NAMES)
    end

    it 'returns all power equipment names when power is missing' do
      settlement = double('Settlement', base_units: [o2_unit], operational_data: {})
      missing = described_class.missing_for_survival(settlement)
      
      expect(missing).not_to include(*Logistics::ISRUCapabilityManager::O2_EQUIPMENT_NAMES)
      expect(missing).to include(*Logistics::ISRUCapabilityManager::POWER_EQUIPMENT_NAMES)
    end

    it 'returns all missing equipment when neither present' do
      settlement = double('Settlement', base_units: [other_unit], operational_data: {})
      missing = described_class.missing_for_survival(settlement)
      
      expect(missing).to include(*Logistics::ISRUCapabilityManager::O2_EQUIPMENT_NAMES)
      expect(missing).to include(*Logistics::ISRUCapabilityManager::POWER_EQUIPMENT_NAMES)
    end

    it 'returns all missing equipment when base_units is empty' do
      settlement = double('Settlement', base_units: [], operational_data: {})
      missing = described_class.missing_for_survival(settlement)
      
      expect(missing).to include(*Logistics::ISRUCapabilityManager::O2_EQUIPMENT_NAMES)
      expect(missing).to include(*Logistics::ISRUCapabilityManager::POWER_EQUIPMENT_NAMES)
    end
  end
end
