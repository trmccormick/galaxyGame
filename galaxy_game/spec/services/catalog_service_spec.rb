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
end
