require 'rails_helper'
require 'fileutils'

RSpec.describe Lookup::CraftLookupService do
  let(:service) { described_class.new }
  let(:test_craft_path) { Rails.root.join('spec', 'fixtures', 'crafts') }
  
  before(:all) do
    # Create test directory structure
    FileUtils.mkdir_p(Rails.root.join('spec', 'fixtures', 'crafts', 'transport', 'spaceships'))
    FileUtils.mkdir_p(Rails.root.join('spec', 'fixtures', 'crafts', 'deployable', 'probes'))
    FileUtils.mkdir_p(Rails.root.join('spec', 'fixtures', 'crafts', 'surface', 'rovers'))
  end

  after(:all) do
    # Clean up test directories
    FileUtils.rm_rf(Rails.root.join('spec', 'fixtures', 'crafts'))
  end

  before do
    # Stub the CRAFT_PATHS constant
    stub_const("#{described_class}::CRAFT_PATHS", {
      'deployable' => test_craft_path.join('deployable'),
      'surface' => test_craft_path.join('surface'),
      'transport' => test_craft_path.join('transport')
    })

    # Allow directory existence checks
    allow(Dir).to receive(:exist?).and_return(true)
  end

  describe '#find_craft' do
    let(:craft_data) do
      {
        'name' => 'starship',
        'type' => 'spaceships',
        'operational_data' => {
          'recommended_units' => [
            { 'id' => 'propulsion', 'count' => 6 }
          ]
        }
      }
    end

    it 'finds craft by name and type' do
      allow(Dir).to receive(:exist?).and_return(true)
      allow(Dir).to receive(:glob).and_return([
        test_craft_path.join('transport', 'spaceships', 'starship.json').to_s
      ])
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:read).and_return(craft_data.to_json)

      result = service.find_craft('starship', 'spaceships')
      expect(result['name']).to eq('starship')
      expect(result['type']).to eq('spaceships')
    end

    context 'when searching for transport craft' do
      let(:craft_type) { 'spaceships' }
      let(:craft_data) do
        {
          "name" => "starship",
          "type" => "spaceships",
          "operational_data" => {
            "recommended_units" => [
              { "id" => "propulsion", "count" => 6 },
              { "id" => "lox_tank", "capacity" => 150000 }
            ]
          }
        }
      end

      before do
        File.write(
          File.join(test_craft_path, 'transport', 'spaceships', 'starship.json'),
          craft_data.to_json
        )
      end

      it 'finds transport craft' do
        result = service.find_craft('starship', craft_type)
        expect(result).to eq(craft_data)
      end
    end

    context 'when searching for deployable craft' do
      let(:craft_type) { 'probes' }
      let(:craft_data) do
        {
          "name" => "atmospheric_probe",
          "type" => "probes",
          "operational_data" => {
            "sensor_range" => 100,
            "atmospheric_entry_rating" => "high"
          }
        }
      end

      before do
        File.write(
          File.join(test_craft_path, 'deployable', 'probes', 'atmospheric_probe.json'),
          craft_data.to_json
        )
      end

      it 'finds deployable craft' do
        result = service.find_craft('atmospheric_probe', craft_type)
        expect(result).to eq(craft_data)
      end
    end

    context 'when searching for transport craft' do
      let(:craft_type) { 'spaceships' }
      let(:craft_data) do
        {
          "name" => "falcon",
          "type" => "spaceships",
          "class" => "light_freighter"
        }
      end

      before do
        File.write(
          File.join(test_craft_path, 'transport', 'spaceships', 'falcon.json'),
          craft_data.to_json
        )
      end

      it 'finds transport craft' do
        result = service.find_craft('falcon', craft_type)
        expect(result).to eq(craft_data)
      end
    end

    context 'when searching for deployable craft' do
      let(:craft_type) { 'probes' }
      let(:craft_data) do
        {
          "name" => "voyager",
          "type" => "probes",
          "class" => "deep_space"
        }
      end

      before do
        File.write(
          File.join(test_craft_path, 'deployable', 'probes', 'voyager.json'),
          craft_data.to_json
        )
      end

      it 'finds deployable craft' do
        result = service.find_craft('voyager', craft_type)
        expect(result).to eq(craft_data)
      end
    end

    context 'when searching for surface craft' do
      let(:craft_type) { 'rovers' }
      let(:craft_data) do
        {
          "name" => "curiosity",
          "type" => "rovers",
          "class" => "exploration"
        }
      end

      before do
        File.write(
          File.join(test_craft_path, 'surface', 'rovers', 'curiosity.json'),
          craft_data.to_json
        )
      end

      it 'finds surface craft' do
        result = service.find_craft('curiosity', craft_type)
        expect(result).to eq(craft_data)
      end
    end

    context 'with invalid inputs' do
      it 'raises ArgumentError for empty craft name' do
        expect {
          service.find_craft('', 'spaceships')
        }.to raise_error(ArgumentError, 'Invalid craft name')
      end

      it 'raises ArgumentError for invalid craft type' do
        expect {
          service.find_craft('falcon', 'invalid_type')
        }.to raise_error(ArgumentError, /Invalid craft type/)
      end
    end

    context 'with caching' do
      let(:craft_data) do
        {
          "name" => "starship",
          "type" => "spaceships",
          "operational_data" => {
            "recommended_units" => [
              { "id" => "propulsion", "count" => 6 }
            ]
          }
        }
      end

      it 'caches and returns cached results' do
        # Mock the file system operations
        allow(Dir).to receive(:glob).and_return([
          test_craft_path.join('transport', 'spaceships', 'starship.json').to_s
        ])
        allow(File).to receive(:exist?).and_return(true)
        
        # Expect File.read to be called exactly once
        expect(File).to receive(:read)
          .with(test_craft_path.join('transport', 'spaceships', 'starship.json').to_s)
          .once
          .and_return(craft_data.to_json)
        
        # Call find_craft twice
        2.times do
          result = service.find_craft('starship', 'spaceships')
          expect(result).to eq(craft_data)
        end
      end
    end

    context 'with invalid JSON' do
      it 'handles invalid JSON files' do
        allow(Dir).to receive(:glob).and_return([
          test_craft_path.join('transport', 'spaceships', 'invalid.json').to_s
        ])
        
        allow(File).to receive(:read)
          .with(test_craft_path.join('transport', 'spaceships', 'invalid.json').to_s)
          .and_return('invalid json')

        result = service.find_craft("invalid", "spaceships")
        expect(result).to be_nil
      end
    end

    context 'with missing files' do
      it 'handles missing craft files' do
        result = service.find_craft('nonexistent', 'spaceships')
        expect(result).to be_nil
      end
    end

    context 'with directory errors' do
      before do
        FileUtils.rm_rf(File.join(test_craft_path, 'transport', 'spaceships'))
      end

      it 'raises error for missing directory' do
        allow(Dir).to receive(:exist?).and_return(false)
        
        expect {
          service.find_craft('falcon', 'spaceships')
        }.to raise_error(/Invalid craft directory structure/)
      end
    end

    context 'with directory errors' do
      before do
        # Override the global Dir.exist? mock for this specific context
        allow(Dir).to receive(:exist?).with(anything).and_return(true)
        allow(Dir).to receive(:exist?)
          .with(test_craft_path.join('transport', 'spaceships'))
          .and_return(false)
      end

      it 'raises error for missing directory' do
        expect {
          service.find_craft('starship', 'spaceships')
        }.to raise_error(/Invalid craft directory structure/)
      end
    end
  end
end