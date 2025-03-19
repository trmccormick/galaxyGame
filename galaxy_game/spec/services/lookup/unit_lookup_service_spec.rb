require 'rails_helper'

RSpec.describe Lookup::UnitLookupService do
  let(:service) { described_class.new }

  describe '#find_unit' do
    it 'finds unit by id' do
      result = service.find_unit('lox_storage_tank')
      expect(result['name']).to eq('LOX Storage Tank')
      expect(result['capacity']).to eq(150000)
    end

    it 'returns nil when unit does not exist' do
      result = service.find_unit('nonexistent_unit')
      expect(result).to be_nil
    end

    it 'caches results' do
      first_result = service.find_unit('lox_storage_tank')
      second_result = service.find_unit('lox_storage_tank')
      expect(first_result.object_id).to eq(second_result.object_id)
    end
  end

  describe '#units' do
    it 'loads all units' do
      units = service.units
      expect(units.keys).to include('storage', 'propulsion', 'housing')
      
      storage_units = units['storage']
      expect(storage_units).to include(
        a_hash_including('name' => 'LOX Storage Tank')
      )
    end
  end
end


