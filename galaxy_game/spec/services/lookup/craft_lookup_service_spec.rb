require 'rails_helper'

RSpec.describe Lookup::CraftLookupService do
  let(:service) { described_class.new }

  describe '#find_craft' do
    it 'finds craft by name, type and sub_type' do
      result = service.find_craft('starship', 'transport', 'spaceship')
      expect(result['name']).to eq('Starship')
      expect(result['type']).to eq('transport')
      expect(result['sub_type']).to eq('spaceships')
    end

    context 'when searching for transport craft' do
      it 'finds transport craft' do
        result = service.find_craft('starship', 'transport', 'spaceship')
        expect(result).to be_a(Hash)
        expect(result['name']).to eq('Starship')
      end
    end

    context 'when searching for deployable craft' do
      it 'finds deployable craft' do
        result = service.find_craft('atmospheric_probe', 'deployable', 'probes')
        expect(result).to be_a(Hash)
        expect(result['name']).to eq('atmospheric_probe')
      end
    end

    context 'when searching for transport craft 2' do
      it 'finds transport craft' do
        result = service.find_craft('falcon', 'transport', 'spaceship')
        expect(result).to be_a(Hash)
        expect(result['name']).to eq('falcon')
      end
    end

    context 'when searching for deployable craft 2' do
      it 'finds deployable craft' do
        result = service.find_craft('voyager', 'deployable', 'probes')
        expect(result).to be_a(Hash)
        expect(result['name']).to eq('voyager')
      end
    end

    context 'when searching for surface craft' do
      it 'finds surface craft' do
        result = service.find_craft('curiosity', 'surface', 'rovers')
        expect(result).to be_a(Hash)
        expect(result['name']).to eq('curiosity')
      end
    end

    context 'with invalid inputs' do
      it 'raises ArgumentError for empty craft name' do
        expect {
          service.find_craft('', 'transport', 'spaceship')
        }.to raise_error(ArgumentError, 'Invalid craft name')
      end

      it 'raises ArgumentError for invalid craft type' do
        expect {
          service.find_craft('falcon', 'invalid_type', 'spaceship')
        }.to raise_error(ArgumentError, /Invalid craft type/)
      end
    end

    context 'with caching' do
      it 'caches and returns cached results' do
        expect(File).to receive(:read).once.and_call_original

        2.times do
          result = service.find_craft('starship', 'transport', 'spaceship')
          expect(result).to be_a(Hash)
          expect(result['name']).to eq('Starship')
        end
      end
    end

    context 'with invalid JSON' do
      it 'handles invalid JSON files' do
        # We assume that there is no file named invalid.json, if there is please remove it from the testing directory.
        result = service.find_craft("invalid", "transport", "spaceship")
        expect(result).to be_nil
      end
    end

    context 'with missing files' do
      it 'handles missing craft files' do
        result = service.find_craft('nonexistent', 'transport', 'spaceship')
        expect(result).to be_nil
      end
    end

    context 'with directory errors' do
      it 'raises error for missing directory' do
        expect {
          service.find_craft('falcon', 'transport', 'nonexistent_directory')
        }.to raise_error(/Invalid craft directory structure/)
      end
    end
  end
end