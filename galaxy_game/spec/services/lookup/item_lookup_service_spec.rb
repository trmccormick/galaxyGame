require 'rails_helper'
require 'fileutils'
require 'json'

RSpec.describe Lookup::ItemLookupService do
  let(:test_data_dir) { Rails.root.join('tmp', 'test', 'items') }
  let(:service) { described_class.new }

  before(:each) do
    # Create test directories and stub BASE_PATH
    stub_const("#{described_class}::BASE_PATH", test_data_dir)
    
    described_class::CATEGORIES.each do |_, folder|
      FileUtils.mkdir_p(test_data_dir.join(folder))
    end

    # Create test data
    create_test_data('battery_pack', 'consumable', {
      'name' => 'Battery Pack',
      'description' => 'A rechargeable battery pack'
    })
    
    create_test_data('medium_plastic_crate', 'container', {
      'name' => 'Medium Plastic Crate',
      'capacity' => 50
    })

    create_test_data('processed_regolith', 'material', {
      'name' => 'Processed Regolith',
      'composition' => {
        'oxides' => { 'SiO2' => 45.0 },
        'minerals' => { 'Ilmenite' => 5.0 }
      }
    })
  end

  after(:each) do
    FileUtils.rm_rf(test_data_dir)
  end

  describe '#find_item' do
    context 'with valid categories' do
      it 'finds consumable items' do
        result = service.find_item('battery_pack', 'consumable')
        expect(result).to include(
          'name' => 'Battery Pack',
          'category' => 'consumable'
        )
      end

      it 'finds container items' do
        result = service.find_item('medium_plastic_crate', 'container')
        expect(result).to include(
          'name' => 'Medium Plastic Crate',
          'category' => 'container'
        )
      end

      it 'finds processed materials' do
        result = service.find_item('processed_regolith', 'material')
        expect(result).to include(
          'name' => 'Processed Regolith',
          'category' => 'material',
          'composition' => hash_including('oxides', 'minerals')
        )
      end
    end

    context 'with invalid inputs' do
      it 'raises ArgumentError for invalid category' do
        expect {
          service.find_item('battery_pack', 'invalid')
        }.to raise_error(ArgumentError, /Invalid category/)
      end

      it 'returns nil for empty item name' do
        expect(service.find_item('')).to be_nil
      end
    end

    context 'with caching' do
      it 'caches and returns cached results' do
        expect(File).to receive(:read).once.and_call_original
        
        2.times do
          result = service.find_item('battery_pack', 'consumable')
          expect(result).to include('name' => 'Battery Pack')
        end
      end
    end
  end

  private

  def create_test_data(name, category, data)
    data['category'] = category
    folder = described_class::CATEGORIES[category]
    path = test_data_dir.join(folder)
    FileUtils.mkdir_p(path)
    File.write(path.join("#{name}_data.json"), JSON.generate(data))
  end
end


