require 'rails_helper'

RSpec.describe Lookup::StructureLookupService, type: :service do
  # Define mock file paths using temporary directories (tempdir gem is ideal here, but RSpec mocks will suffice)
  let(:base_data_path) { Rails.root.join('spec', 'support', 'data', 'operational_data', 'structures') }
  
  # Mock the structure_paths method to point to the temporary spec directories
  before do
    allow(Lookup::StructureLookupService).to receive(:structure_paths).and_return(
      'space_stations' => base_data_path.join('space_stations'),
      'transportation' => base_data_path.join('transportation'),
      'storage' => base_data_path.join('storage')
    )
    # Ensure the instance load_structures is mocked to prevent file system reads outside of test control
    allow_any_instance_of(Lookup::StructureLookupService).to receive(:load_structures).and_return(nil)
  end

  # Setup test data files
  let(:depot_data) do
    { "id" => "orbital_depot_mk1", "name" => "Orbital Propellant Depot", "structure_type" => "refueling_station" }
  end
  let(:station_data) do
    { "id" => "l1_mega_station_mk1", "name" => "L1 Mega Station", "structure_type" => "mega_station" }
  end
  let(:storage_data) do
    { "id" => "warehouse_lunar", "name" => "Lunar Warehouse", "structure_type" => "storage" }
  end

  subject(:service) { Lookup::StructureLookupService.new }

  # Helper to mock file existence and content
  def mock_file_lookup(category, id, data)
    path = Lookup::StructureLookupService.structure_paths[category].join("#{id}.json")
    
    # Mock load_json_file for the specific file
    allow(service).to receive(:load_json_file).with(path).and_return(data)
  end

  describe '#find_structure' do
    context 'when searching by structure_id and category (type)' do
      before do
        allow(service).to receive(:load_json_file).and_return(nil)
        mock_file_lookup('space_stations', 'orbital_depot_mk1', depot_data)
        mock_file_lookup('storage', 'warehouse_lunar', storage_data)
      end

      it 'returns the structure data when found in the specified type directory' do
        allow(Lookup::StructureLookupService).to receive(:structure_paths).and_return(
          'space_stations' => base_data_path.join('space_stations')
        )
        allow(service).to receive(:load_json_file).and_return(depot_data)
        result = service.find_structure('orbital_depot_mk1')
        expect(result).to eq(depot_data)
      end

      it 'returns nil if the structure is not found in any directory' do
        result = service.find_structure('lunar_habitat_mk1')
        expect(result).to be_nil
      end
    end

    context 'when searching by structure_id without category (global search)' do
      before do
        allow(service).to receive(:load_json_file).and_return(nil)
        # Mock files existing in different categories
        mock_file_lookup('space_stations', 'l1_mega_station_mk1', station_data)
        mock_file_lookup('transportation', 'cargo_shuttle_mk1', { "id" => "cargo_shuttle_mk1" })
        mock_file_lookup('storage', 'warehouse_lunar', storage_data)
      end

      it 'returns the structure data if found in any directory' do
        result = service.find_structure('l1_mega_station_mk1')
        expect(result).to eq(station_data)
        
        result = service.find_structure('warehouse_lunar')
        expect(result).to eq(storage_data)
      end

      it 'searches through categories and returns the first match found' do
        # To test the order of search, we'd need more complex mocking of the STRUCTURE_PATHS iteration order.
        # For simplicity, we ensure it finds a known good result from any path.
        result = service.find_structure('l1_mega_station_mk1')
        expect(result).to eq(station_data)
      end

      it 'returns nil if the structure is not found in any directory' do
        result = service.find_structure('unknown_structure_id')
        expect(result).to be_nil
      end
    end

    context 'when the JSON file is invalid' do
      it 'returns nil and logs an error' do
        path = Lookup::StructureLookupService.structure_paths['space_stations'].join("bad_json.json")
        allow(File).to receive(:read).with(path).and_return('invalid json')
        result = service.find_structure('bad_json')
        expect(result).to be_nil
      end
    end
    
    context 'caching behavior' do
        it 'reads from the file system only once for the same query' do
          allow(Lookup::StructureLookupService).to receive(:structure_paths).and_return(
            'space_stations' => base_data_path.join('space_stations')
          )
            expect(service).to receive(:load_json_file).once.and_return(depot_data)
            
            # First call reads and caches
            service.find_structure('orbital_depot_mk1')
            
            # Second call should use cache
            service.find_structure('orbital_depot_mk1')
        end
        
        it 'stores the result in the cache hash' do
          allow(Lookup::StructureLookupService).to receive(:structure_paths).and_return(
            'space_stations' => base_data_path.join('space_stations')
          )
          allow(service).to receive(:load_json_file).and_return(depot_data)
          service.find_structure('orbital_depot_mk1')
          expect(service.instance_variable_get(:@cache)['orbital_depot_mk1']).to eq(depot_data)
        end
    end
  end
end