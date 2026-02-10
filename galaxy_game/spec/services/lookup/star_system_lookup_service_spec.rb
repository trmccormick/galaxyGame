require 'rails_helper'

RSpec.describe Lookup::StarSystemLookupService do
  let(:service) { described_class.new }

  describe '#fetch' do
    context 'with curated systems' do
      it 'finds system by name' do
        result = service.fetch('Sol')
        expect(result).to be_present
        expect(result[:solar_system][:name]).to eq('Sol')
      end

      it 'finds system by identifier' do
        result = service.fetch('SOL-01')
        expect(result).to be_present
        expect(result[:solar_system][:identifier]).to eq('SOL-01')
      end
    end

    context 'with generated systems' do
      it 'finds system by solar_system identifier' do
        result = service.fetch('AOL-732356')
        expect(result).to be_present
        expect(result[:solar_system][:identifier]).to eq('AOL-732356')
        expect(result[:solar_system][:name]).to eq('Eden')
      end

      it 'finds system by source file name (case insensitive)' do
        result = service.fetch('aol-732356')
        expect(result).to be_present
        expect(result[:solar_system][:identifier]).to eq('AOL-732356')
      end
    end

    context 'when system not found' do
      it 'returns nil for non-existent system' do
        result = service.fetch('NON_EXISTENT_SYSTEM')
        expect(result).to be_nil
      end
    end
  end

  describe '#system_exists?' do
    it 'returns true for existing systems' do
      expect(service.system_exists?('Sol')).to be true
      expect(service.system_exists?('AOL-732356')).to be true
    end

    it 'returns false for non-existent systems' do
      expect(service.system_exists?('NON_EXISTENT')).to be false
    end
  end
end