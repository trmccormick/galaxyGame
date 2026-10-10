# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogService do
  let(:service) { described_class.new }

  describe '#base_path' do
    it 'returns a Pathname' do
      expect(service.base_path).to be_a(Pathname)
    end

    it 'returns an existing directory' do
      expect(service.base_path.exist?).to be true
      expect(service.base_path.directory?).to be true
    end
  end

  describe '#entries' do
    it 'returns an array' do
      expect(service.entries).to be_an(Array)
    end

    it 'caches entries per request' do
      first_call = service.entries
      second_call = service.entries
      expect(first_call.object_id).to eq(second_call.object_id)
    end

    it 'sorts entries if any exist' do
      entries = service.entries
      skip 'No entries to sort' if entries.empty?
      
      (0...(entries.size - 1)).each do |i|
        current = [entries[i][:category], entries[i][:subcategory] || '', entries[i][:name]]
        next_item = [entries[i + 1][:category], entries[i + 1][:subcategory] || '', entries[i + 1][:name]]
        expect(current <=> next_item).to be <= 0
      end
    end
  end

  describe '#find_entry' do
    it 'returns nil for non-existent id' do
      expect(service.find_entry('nonexistent/path.json')).to be_nil
    end

    it 'returns entry hash if it exists' do
      entries = service.entries
      skip 'No entries available' if entries.empty?
      
      first_entry = entries.first
      found = service.find_entry(first_entry[:id])
      expect(found[:id]).to eq(first_entry[:id])
    end
  end

  describe '#entries_for' do
    it 'returns array for category filter' do
      result = service.entries_for(category: 'units')
      expect(result).to be_an(Array)
    end

    it 'filters by category correctly' do
      entries = service.entries
      skip 'No entries available' if entries.empty?
      
      result = service.entries_for(category: entries.first[:category])
      expect(result.map { |e| e[:category] }).to all(eq(entries.first[:category]))
    end

    it 'returns array for search filter' do
      result = service.entries_for(search: 'test')
      expect(result).to be_an(Array)
    end
  end

  describe '#paginated_result' do
    let(:test_entries) {
      [
        { id: '1', name: 'Entry 1', category: 'units', type: 'test' },
        { id: '2', name: 'Entry 2', category: 'units', type: 'test' },
        { id: '3', name: 'Entry 3', category: 'units', type: 'test' }
      ]
    }

    it 'returns an object with pagination methods' do
      result = service.paginated_result(test_entries, page: 1, per_page: 2)
      expect(result).to respond_to(:total_count)
      expect(result).to respond_to(:total_pages)
      expect(result).to respond_to(:current_page)
      expect(result).to respond_to(:to_a)
      expect(result).to respond_to(:first_page?)
      expect(result).to respond_to(:last_page?)
    end

    it 'returns correct total count' do
      result = service.paginated_result(test_entries, page: 1, per_page: 2)
      expect(result.total_count).to eq(3)
    end

    it 'calculates total pages correctly' do
      result = service.paginated_result(test_entries, page: 1, per_page: 2)
      expect(result.total_pages).to eq(2)  # ceil(3/2) = 2
    end

    it 'returns correct page items' do
      result = service.paginated_result(test_entries, page: 1, per_page: 2)
      expect(result.to_a.size).to eq(2)
      expect(result.to_a.map { |e| e[:id] }).to eq(['1', '2'])
    end

    it 'returns last page items' do
      result = service.paginated_result(test_entries, page: 2, per_page: 2)
      expect(result.to_a.size).to eq(1)
      expect(result.to_a.map { |e| e[:id] }).to eq(['3'])
    end

    it 'marks first page correctly' do
      result = service.paginated_result(test_entries, page: 1, per_page: 2)
      expect(result.first_page?).to be true
      expect(result.last_page?).to be false
    end

    it 'marks last page correctly' do
      result = service.paginated_result(test_entries, page: 2, per_page: 2)
      expect(result.first_page?).to be false
      expect(result.last_page?).to be true
    end

    it 'handles empty array' do
      result = service.paginated_result([], page: 1, per_page: 2)
      expect(result.total_count).to eq(0)
      expect(result.empty?).to be true
    end
  end

  # C2 — Catalog Data Wiring tests
  describe '#catalog_data' do
    it 'returns nil for unknown asset_id' do
      result = service.catalog_data('UNKNOWN_ASSET_ID')
      expect(result).to be_nil
    end

    it 'returns nil for blank asset_id' do
      result = service.catalog_data('')
      expect(result).to be_nil
    end

    it 'returns a hash with B2 contract fields for registered RH-400 Unit' do
      # Register RH-400 in the registry (C1/C4 already does this, but test isolation)
      registry = AssetRegistry.new
      entry = registry.register_asset(
        asset_id: AssetRegistry::RH400_ASSET_ID,
        blueprint_id: AssetRegistry::RH400_BLUEPRINT_ID,
        asset_family: 'vehicle',
        component_class: 'harvester'
      )

      result = service.catalog_data(AssetRegistry::RH400_ASSET_ID, registry: registry)
      
      expect(result).to be_a(Hash)
      expect(result[:asset_id]).to eq(AssetRegistry::RH400_ASSET_ID)
      expect(result[:blueprint_id]).to eq(AssetRegistry::RH400_BLUEPRINT_ID)
      expect(result[:asset_family]).to eq('vehicle')
      expect(result[:component_class]).to eq('harvester')
      expect(result).to have_key(:blueprint_data)
      expect(result).to have_key(:operational_data)
      expect(result).to have_key(:visual_definition)
      expect(result).to have_key(:catalog_render_path)
      expect(result).to have_key(:inventory_icon_path)
      expect(result).to have_key(:representation_status)
    end

    it 'includes operational_data key for Units/Structures/Vehicles (may be nil if no file)' do
      registry = AssetRegistry.new
      registry.register_asset(
        asset_id: 'VEHICLE_TEST_ROVER_T001',
        blueprint_id: 'test_rover',
        asset_family: 'vehicle',
        component_class: 'rover'
      )

      result = service.catalog_data('VEHICLE_TEST_ROVER_T001', registry: registry)
      
      # The key must exist in the contract for Units/Structures/Vehicles
      expect(result).to have_key(:operational_data)
      # Value may be nil if no operational data file exists on disk — that is correct
    end

    it 'excludes operational_data for Components (I-beam case)' do
      registry = AssetRegistry.new
      registry.register_asset(
        asset_id: 'COMPONENT_I_BEAM_MK1',
        blueprint_id: 'i_beam_mk1',
        asset_family: 'component',
        component_class: 'structural'
      )

      result = service.catalog_data('COMPONENT_I_BEAM_MK1', registry: registry)
      
      expect(result).to be_a(Hash)
      expect(result[:asset_family]).to eq('component')
      # Components must NOT have operational_data — no fake/empty sections
      expect(result[:operational_data]).to be_nil
    end

    it 'does not generate fake Operational Data for Components' do
      registry = AssetRegistry.new
      registry.register_asset(
        asset_id: 'COMPONENT_PANEL_MK1',
        blueprint_id: 'panel_mk1',
        asset_family: 'component',
        component_class: 'structural'
      )

      result = service.catalog_data('COMPONENT_PANEL_MK1', registry: registry)
      
      expect(result[:operational_data]).to be_nil
      # Verify the contract still has all required fields minus operational_data
      expect(result[:asset_id]).to eq('COMPONENT_PANEL_MK1')
      expect(result[:blueprint_id]).to eq('panel_mk1')
    end

    it 'preserves existing catalog behavior — entries_for unchanged' do
      # Verify the new wiring does not break existing CatalogService functionality
      entries = service.entries_for(category: nil)
      expect(entries).to be_an(Array)
    end
  end
end
