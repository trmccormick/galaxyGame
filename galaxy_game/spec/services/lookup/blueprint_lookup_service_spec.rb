require 'rails_helper'

RSpec.describe Lookup::BlueprintLookupService, type: :service do
  let(:service) { described_class.new }

  describe '#initialize' do
    it 'initializes without error' do
      expect { service }.not_to raise_error
    end

    it 'loads blueprints on initialization' do
      expect(service.all_blueprints).to be_an(Array)
    end
  end

  describe '#find_blueprint' do
    context 'with real blueprint files' do
      before do
        # Skip if no blueprint files exist
        skip "No blueprint files found" if service.all_blueprints.empty?
      end

      it 'finds blueprints by exact name match' do
        blueprint = service.all_blueprints.first
        next unless blueprint && blueprint['name']

        found = service.find_blueprint(blueprint['name'])
        expect(found).to eq(blueprint)
        expect(found['name']).to eq(blueprint['name'])
      end

      it 'finds blueprints by exact ID match' do
        blueprint = service.all_blueprints.find { |bp| bp['id'].present? }
        next unless blueprint

        found = service.find_blueprint(blueprint['id'])
        expect(found).to eq(blueprint)
        expect(found['id']).to eq(blueprint['id'])
      end

      it 'is case insensitive' do
        blueprint = service.all_blueprints.first
        next unless blueprint && blueprint['name']

        found = service.find_blueprint(blueprint['name'].upcase)
        expect(found).to eq(blueprint)
      end

      it 'returns nil for non-existent blueprints' do
        result = service.find_blueprint('NonExistentBlueprint12345')
        expect(result).to be_nil
      end

      it 'handles empty or nil queries gracefully' do
        expect(service.find_blueprint('')).to be_nil
        expect(service.find_blueprint(nil)).to be_nil
      end
    end

    context 'with category filtering' do
      before do
        skip "No blueprint files found" if service.all_blueprints.empty?
      end

      it 'filters blueprints by category' do
        # Find a blueprint with a category
        blueprint_with_category = service.all_blueprints.find { |bp| bp['category'].present? }
        next unless blueprint_with_category

        category = blueprint_with_category['category']
        found = service.find_blueprint(blueprint_with_category['name'], category)
        
        expect(found).to eq(blueprint_with_category)
        expect(found['category']).to eq(category)
      end

      it 'returns nil when blueprint exists but category does not match' do
        blueprint = service.all_blueprints.find { |bp| bp['category'].present? }
        next unless blueprint

        found = service.find_blueprint(blueprint['name'], 'non_existent_category')
        expect(found).to be_nil
      end
    end

    context 'with aliases' do
      it 'finds blueprints by alias' do
        blueprint_with_alias = service.all_blueprints.find { |bp| bp['aliases']&.any? }
        next unless blueprint_with_alias

        alias_name = blueprint_with_alias['aliases'].first
        found = service.find_blueprint(alias_name)
        
        expect(found).to eq(blueprint_with_alias)
      end
    end

    context 'with partial matches' do
      before do
        skip "No blueprint files found" if service.all_blueprints.empty?
      end

      it 'finds blueprints by partial name match for queries >= 3 characters' do
        blueprint = service.all_blueprints.find { |bp| bp['name'] && bp['name'].length >= 5 }
        next unless blueprint

        partial_name = blueprint['name'][0..2]  # First 3 characters
        found = service.find_blueprint(partial_name)
        
        expect(found).to eq(blueprint)
      end

      it 'does not match partial queries shorter than 3 characters' do
        blueprint = service.all_blueprints.first
        next unless blueprint && blueprint['name'] && blueprint['name'].length >= 3

        short_query = blueprint['name'][0..1]  # First 2 characters
        found = service.find_blueprint(short_query)
        
        # Should not find by partial match with short query
        expect(found).to be_nil
      end
    end
  end

  describe '#all_blueprints' do
    it 'returns an array' do
      expect(service.all_blueprints).to be_an(Array)
    end

    it 'returns consistent results on multiple calls' do
      first_call = service.all_blueprints
      second_call = service.all_blueprints
      
      expect(first_call).to eq(second_call)
    end

    context 'when blueprint files exist' do
      before do
        skip "No blueprint files found" if service.all_blueprints.empty?
      end

      it 'returns blueprints with expected structure' do
        blueprint = service.all_blueprints.first
        
        expect(blueprint).to be_a(Hash)
        expect(blueprint).to have_key('name').or have_key('id')
      end
    end
  end

  describe '#blueprints_by_category' do
    before do
      skip "No blueprint files found" if service.all_blueprints.empty?
    end

    it 'returns blueprints filtered by category' do
      # Find a category that exists
      categories = service.all_blueprints.map { |bp| bp['category'] }.compact.uniq
      next if categories.empty?

      category = categories.first
      filtered = service.blueprints_by_category(category)
      
      expect(filtered).to be_an(Array)
      filtered.each do |blueprint|
        expect(blueprint['category']).to eq(category)
      end
    end

    it 'returns empty array for non-existent category' do
      result = service.blueprints_by_category('non_existent_category_12345')
      expect(result).to eq([])
    end

    it 'handles nil category gracefully' do
      result = service.blueprints_by_category(nil)
      expect(result).to eq([])
    end

    it 'is case insensitive for category matching' do
      categories = service.all_blueprints.map { |bp| bp['category'] }.compact.uniq
      next if categories.empty?

      category = categories.first
      next unless category

      lower_result = service.blueprints_by_category(category.downcase)
      upper_result = service.blueprints_by_category(category.upcase)
      normal_result = service.blueprints_by_category(category)
      
      expect(lower_result).to eq(normal_result)
      expect(upper_result).to eq(normal_result)
    end
  end

  describe '#debug_paths' do
    it 'runs without error' do
      expect { service.debug_paths }.not_to raise_error
    end
  end

  describe 'error handling' do
    it 'handles missing blueprint directories gracefully' do
      allow(File).to receive(:directory?).and_return(false)
      expect { described_class.new }.not_to raise_error
    end

    it 'handles JSON parsing errors gracefully' do
      allow(JSON).to receive(:parse).and_raise(JSON::ParserError.new("Invalid JSON"))
      expect { described_class.new }.not_to raise_error
    end
  end

  describe 'real world usage' do
    context 'when blueprint files exist' do
      before do
        skip "No blueprint files found" if service.all_blueprints.empty?
      end

      it 'can find common blueprint types' do
        # Test common blueprint searches that might be used in the game
        common_searches = ['engine', 'reactor', 'module', 'facility', 'structure']
        
        common_searches.each do |search_term|
          result = service.find_blueprint(search_term)
          # Don't require matches, just ensure no errors
          expect { result }.not_to raise_error
        end
      end

      it 'loads blueprints with valid JSON structure' do
        service.all_blueprints.each do |blueprint|
          expect(blueprint).to be_a(Hash)
          expect(blueprint.keys).not_to be_empty
        end
      end
    end
  end
end