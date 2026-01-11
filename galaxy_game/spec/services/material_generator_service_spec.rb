require 'rails_helper'
require_relative '../../app/services/material_generator_service'
require_relative '../../app/services/lookup/material_lookup_service'

RSpec.describe MaterialGeneratorService do
  describe '.generate_material' do
    let(:water_data) do
      {
        'id' => 'water',
        'name' => 'Water',
        'chemical_formula' => 'H2O'
      }
    end

    before do
      material_lookup = instance_double(Lookup::MaterialLookupService)
      allow(Lookup::MaterialLookupService).to receive(:new).and_return(material_lookup)
      allow(material_lookup).to receive(:find_material).with('water').and_return(water_data)
      allow(material_lookup).to receive(:find_material).with('unknown').and_return(nil)
    end

    it 'returns material data for water' do
      result = described_class.generate_material('water')
      expect(result).to be_a(Hash)
      expect(result['id']).to eq('water')
      expect(result['name']).to eq('Water')
      expect(result['chemical_formula']).to eq('H2O')
    end

    it 'returns nil for unknown material' do
      result = described_class.generate_material('unknown')
      expect(result).to be_nil
    end
  end
end