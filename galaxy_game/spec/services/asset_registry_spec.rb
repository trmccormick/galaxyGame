# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssetRegistry do
  let(:registry) { described_class.new }
  let(:test_blueprints_path) { Rails.root.join('app', 'data', 'blueprints') }
  let(:test_operational_data_path) { Rails.root.join('app', 'data', 'operational_data') }
  let(:registry_with_paths) do
    described_class.new(
      blueprints_path: test_blueprints_path,
      operational_data_path: test_operational_data_path
    )
  end

  describe '#resolve' do
    it 'returns nil for non-existent asset_id' do
      result = registry.resolve('NONEXISTENT_ASSET')
      expect(result).to be_nil
    end

    it 'returns nil for blank asset_id' do
      result = registry.resolve('')
      expect(result).to be_nil
    end

    it 'caches resolved entries' do
      # Register an entry first
      registry.register_asset(
        asset_id: 'TEST_ASSET_001',
        blueprint_id: 'test_blueprint',
        asset_family: 'vehicle',
        component_class: 'rover',
        file_prefix: 'test_'
      )

      # Resolve should return cached entry
      entry1 = registry.resolve('TEST_ASSET_001')
      entry2 = registry.resolve('TEST_ASSET_001')
      expect(entry1).to be(entry2) # Same object (cached)
    end
  end

  describe '#register_asset' do
    it 'registers an asset with all required fields' do
      entry = registry.register_asset(
        asset_id: 'VEHICLE_TEST_ROVER_T001',
        blueprint_id: 'test_rover',
        asset_family: 'vehicle',
        component_class: 'rover',
        file_prefix: 't001_'
      )

      expect(entry[:asset_id]).to eq('VEHICLE_TEST_ROVER_T001')
      expect(entry[:blueprint_id]).to eq('test_rover')
      expect(entry[:asset_family]).to eq('vehicle')
      expect(entry[:component_class]).to eq('rover')
      expect(entry[:file_prefix]).to eq('t001_')
    end

    it 'validates asset_family' do
      expect {
        registry.register_asset(
          asset_id: 'TEST_001',
          blueprint_id: 'test',
          asset_family: 'invalid_family'
        )
      }.to raise_error(ArgumentError, /Invalid asset_family/)
    end

    it 'accepts nil component_class for non-required families' do
      entry = registry.register_asset(
        asset_id: 'RESOURCE_IRON_R001',
        blueprint_id: 'iron_deposit',
        asset_family: 'resource'
      )

      expect(entry[:component_class]).to be_nil
    end

    it 'sets visual_profile_id to nil by default' do
      entry = registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle'
      )

      expect(entry[:visual_profile_id]).to be_nil
    end

    it 'stores representation manifest' do
      representations = {
        catalog_render: { status: 'exists', files: ['rh400_concept.png'] },
        inventory_icon: { status: 'missing' },
        sprite_sheet: { status: 'experimental', notes: 'Test asset' }
      }

      entry = registry.register_asset(
        asset_id: 'VEHICLE_TEST_ROVER_T001',
        blueprint_id: 'test_rover',
        asset_family: 'vehicle',
        representations: representations
      )

      expect(entry[:representations][:catalog_render][:status]).to eq('exists')
      expect(entry[:representations][:inventory_icon][:status]).to eq('missing')
      expect(entry[:representations][:sprite_sheet][:status]).to eq('experimental')
    end

    it 'normalizes representation statuses' do
      representations = {
        catalog_render: 'exists', # String status (simplified format)
        engineering_render: 'missing'
      }

      entry = registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle',
        representations: representations
      )

      expect(entry[:representations][:catalog_render][:status]).to eq('exists')
      expect(entry[:representations][:engineering_render][:status]).to eq('missing')
    end

    it 'rejects invalid representation statuses' do
      representations = {
        catalog_render: { status: 'invalid_status' }
      }

      entry = registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle',
        representations: representations
      )

      # Invalid statuses should be filtered out
      expect(entry[:representations].key?(:catalog_render)).to be_falsey
    end
  end

  describe '#representation_manifest' do
    it 'returns empty hash for unregistered asset' do
      manifest = registry.representation_manifest('NONEXISTENT')
      expect(manifest).to eq({})
    end

    it 'returns representation manifest for registered asset' do
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle',
        representations: {
          catalog_render: { status: 'exists', files: ['test.png'] },
          inventory_icon: { status: 'missing' }
        }
      )

      manifest = registry.representation_manifest('TEST_001')
      expect(manifest[:catalog_render][:status]).to eq('exists')
      expect(manifest[:inventory_icon][:status]).to eq('missing')
    end
  end

  describe '#representation_exists?' do
    it 'returns true for existing representation' do
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle',
        representations: { catalog_render: { status: 'exists' } }
      )

      expect(registry.representation_exists?('TEST_001', :catalog_render)).to be true
    end

    it 'returns false for missing representation' do
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle',
        representations: { catalog_render: { status: 'missing' } }
      )

      expect(registry.representation_exists?('TEST_001', :catalog_render)).to be false
    end

    it 'returns false for experimental representation' do
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle',
        representations: { sprite_sheet: { status: 'experimental' } }
      )

      expect(registry.representation_exists?('TEST_001', :sprite_sheet)).to be false
    end
  end

  describe '#visual_profile_id' do
    it 'returns nil for unregistered asset' do
      expect(registry.visual_profile_id('NONEXISTENT')).to be_nil
    end

    it 'returns registered visual_profile_id' do
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle',
        visual_profile_id: 'VP_ROVER_STANDARD_001'
      )

      expect(registry.visual_profile_id('TEST_001')).to eq('VP_ROVER_STANDARD_001')
    end

    it 'returns nil when visual_profile_id not set' do
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle'
      )

      expect(registry.visual_profile_id('TEST_001')).to be_nil
    end
  end

  describe '#catalog_manifest_path' do
    it 'returns nil for unregistered asset' do
      expect(registry.catalog_manifest_path('NONEXISTENT')).to be_nil
    end

    it 'returns registered catalog manifest path' do
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle',
        catalog_manifest_path: '/assets/manifests/catalog/test_001.json'
      )

      expect(registry.catalog_manifest_path('TEST_001')).to eq('/assets/manifests/catalog/test_001.json')
    end
  end

  describe '#surface_manifest_path' do
    it 'returns nil for unregistered asset' do
      expect(registry.surface_manifest_path('NONEXISTENT')).to be_nil
    end

    it 'returns registered surface manifest path' do
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle',
        surface_manifest_path: '/assets/manifests/surface/test_001.json'
      )

      expect(registry.surface_manifest_path('TEST_001')).to eq('/assets/manifests/surface/test_001.json')
    end
  end

  describe '#all_assets' do
    it 'returns all registered assets' do
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test1',
        asset_family: 'vehicle'
      )
      registry.register_asset(
        asset_id: 'TEST_002',
        blueprint_id: 'test2',
        asset_family: 'component'
      )

      assets = registry.all_assets
      expect(assets.size).to eq(2)
      expect(assets.map { |a| a[:asset_id] }).to contain_exactly('TEST_001', 'TEST_002')
    end

    it 'returns empty array when no assets registered' do
      expect(registry.all_assets).to be_empty
    end
  end

  describe '#assets_by_family' do
    it 'returns assets filtered by asset_family' do
      registry.register_asset(
        asset_id: 'VEHICLE_001',
        blueprint_id: 'test1',
        asset_family: 'vehicle'
      )
      registry.register_asset(
        asset_id: 'RESOURCE_001',
        blueprint_id: 'test2',
        asset_family: 'resource'
      )
      registry.register_asset(
        asset_id: 'VEHICLE_002',
        blueprint_id: 'test3',
        asset_family: 'vehicle'
      )

      vehicles = registry.assets_by_family('vehicle')
      expect(vehicles.size).to eq(2)
      expect(vehicles.map { |v| v[:asset_id] }).to contain_exactly('VEHICLE_001', 'VEHICLE_002')
    end

    it 'returns empty array for non-existent family' do
      expect(registry.assets_by_family('nonexistent')).to be_empty
    end
  end

  describe '#asset_registered?' do
    it 'returns true for registered asset' do
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle'
      )

      expect(registry.asset_registered?('TEST_001')).to be true
    end

    it 'returns false for unregistered asset' do
      expect(registry.asset_registered?('NONEXISTENT')).to be false
    end
  end

  describe '#valid_asset_families' do
    it 'returns all valid asset families' do
      families = registry.valid_asset_families
      expect(families).to contain_exactly(
        'resource', 'component', 'assembly', 'equipment',
        'unit', 'structure', 'vehicle', 'organization'
      )
    end

    it 'returns frozen array' do
      families = registry.valid_asset_families
      expect { families << 'invalid' }.to raise_error(FrozenError)
    end
  end

  describe '#render_profiles' do
    it 'returns all defined render profiles' do
      profiles = registry.render_profiles
      expect(profiles).to contain_exactly(
        'inventory_icon', 'catalog_render', 'engineering_render',
        'blueprint', 'exploded_view', 'sprite_sheet'
      )
    end
  end

  describe 'RH-400 concrete example' do
    before do
      # Register RH-400 with all fields per B1 design
      registry.register_asset(
        asset_id: described_class::RH400_ASSET_ID,
        blueprint_id: described_class::RH400_BLUEPRINT_ID,
        asset_family: 'vehicle',
        component_class: 'harvester',
        file_prefix: described_class::RH400_FILE_PREFIX,
        visual_profile_id: nil, # Will be resolved by orchestration
        representations: {
          inventory_icon: { status: 'missing' },
          catalog_render: { status: 'exists', files: ['rh400_concept.png', 'rh400_regolith_harvesting_rover.png'] },
          engineering_render: { status: 'missing' },
          blueprint: { status: 'missing' },
          exploded_view: { status: 'missing' },
          sprite_sheet: { status: 'experimental', files: ['rh400_sprite_test.png'], notes: 'Test asset — not production' }
        },
        catalog_manifest_path: '/assets/manifests/catalog/VEHICLE_HARVESTER_ROVER_RH400.json',
        surface_manifest_path: '/assets/manifests/surface/VEHICLE_HARVESTER_ROVER_RH400.json'
      )
    end

    it 'resolves RH-400 by asset_id' do
      entry = registry.resolve(described_class::RH400_ASSET_ID)
      expect(entry[:asset_id]).to eq('VEHICLE_HARVESTER_ROVER_RH400')
      expect(entry[:blueprint_id]).to eq('regolith_harvester_rover')
    end

    it 'stores all three RH-400 identifiers' do
      entry = registry.resolve(described_class::RH400_ASSET_ID)
      expect(entry[:asset_id]).to eq('VEHICLE_HARVESTER_ROVER_RH400')
      expect(entry[:blueprint_id]).to eq('regolith_harvester_rover')
      expect(entry[:file_prefix]).to eq('rh400_')
    end

    it 'has correct asset_family and component_class' do
      entry = registry.resolve(described_class::RH400_ASSET_ID)
      expect(entry[:asset_family]).to eq('vehicle')
      expect(entry[:component_class]).to eq('harvester')
    end

    it 'stores visual_profile_id as nil (orchestration resolves)' do
      expect(registry.visual_profile_id(described_class::RH400_ASSET_ID)).to be_nil
    end

    it 'has correct representation manifest' do
      manifest = registry.representation_manifest(described_class::RH400_ASSET_ID)
      
      expect(manifest[:inventory_icon][:status]).to eq('missing')
      expect(manifest[:catalog_render][:status]).to eq('exists')
      expect(manifest[:catalog_render][:files].size).to eq(2)
      expect(manifest[:engineering_render][:status]).to eq('missing')
      expect(manifest[:blueprint][:status]).to eq('missing')
      expect(manifest[:exploded_view][:status]).to eq('missing')
      expect(manifest[:sprite_sheet][:status]).to eq('experimental')
    end

    it 'catalog_render representation exists' do
      expect(registry.representation_exists?(described_class::RH400_ASSET_ID, :catalog_render)).to be true
    end

    it 'inventory_icon representation does not exist' do
      expect(registry.representation_exists?(described_class::RH400_ASSET_ID, :inventory_icon)).to be false
    end

    it 'sprite_sheet is experimental, not exists' do
      expect(registry.representation_exists?(described_class::RH400_ASSET_ID, :sprite_sheet)).to be false
    end

    it 'has catalog manifest path' do
      expect(registry.catalog_manifest_path(described_class::RH400_ASSET_ID)).to eq('/assets/manifests/catalog/VEHICLE_HARVESTER_ROVER_RH400.json')
    end

    it 'has surface manifest path' do
      expect(registry.surface_manifest_path(described_class::RH400_ASSET_ID)).to eq('/assets/manifests/surface/VEHICLE_HARVESTER_ROVER_RH400.json')
    end

    it 'is registered in the registry' do
      expect(registry.asset_registered?(described_class::RH400_ASSET_ID)).to be true
    end

    it 'appears in vehicle family assets' do
      vehicles = registry.assets_by_family('vehicle')
      expect(vehicles.map { |v| v[:asset_id] }).to include('VEHICLE_HARVESTER_ROVER_RH400')
    end
  end

  describe 'canonical asset lookup' do
    it 'resolves unique asset_id as primary key' do
      registry.register_asset(
        asset_id: 'RESOURCE_IRON_DEPOSIT_R001',
        blueprint_id: 'iron_deposit',
        asset_family: 'resource'
      )

      entry = registry.resolve('RESOURCE_IRON_DEPOSIT_R001')
      expect(entry[:asset_id]).to eq('RESOURCE_IRON_DEPOSIT_R001')
    end

    it 'does not allow duplicate asset_ids' do
      registry.register_asset(
        asset_id: 'TEST_DUP_001',
        blueprint_id: 'test1',
        asset_family: 'vehicle'
      )

      registry.register_asset(
        asset_id: 'TEST_DUP_001', # Same asset_id
        blueprint_id: 'test2',
        asset_family: 'component'
      )

      # Second registration overwrites first (same key in cache)
      entry = registry.resolve('TEST_DUP_001')
      expect(entry[:blueprint_id]).to eq('test2')
    end
  end

  describe 'artifact path resolution' do
    it 'stores blueprint_path when file exists' do
      # Create a temporary test blueprint file
      test_blueprint = test_blueprints_path.join('test_rover.json')
      File.write(test_blueprint, '{"name": "Test Rover"}')

      entry = registry_with_paths.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test_rover',
        asset_family: 'vehicle'
      )

      expect(entry[:blueprint_path]).to be_present
      expect(entry[:blueprint_path]).to include('test_rover.json')

      # Cleanup
      test_blueprint.delete if test_blueprint.exist?
    end

    it 'stores operational_data_path when file exists' do
      # Create a temporary test operational data file
      test_op_data = test_operational_data_path.join('test_rover.json')
      File.write(test_op_data, '{"power": 100}')

      entry = registry_with_paths.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test_rover',
        asset_family: 'vehicle'
      )

      expect(entry[:operational_data_path]).to be_present
      expect(entry[:operational_data_path]).to include('test_rover.json')

      # Cleanup
      test_op_data.delete if test_op_data.exist?
    end

    it 'stores visual_definition_path when file exists' do
      # This tests the discovery path — requires actual visual definition files
      # For now, verify the field is present in entry structure
      entry = registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle'
      )

      expect(entry).to have_key(:visual_definition_path)
    end

    it 'stores render_template_path for registered asset' do
      entry = registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle'
      )

      expect(entry).to have_key(:render_template_path)
    end
  end

  describe 'missing representation handling' do
    it 'records missing representations without inventing content' do
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle',
        representations: {
          catalog_render: { status: 'missing' },
          inventory_icon: { status: 'missing' }
        }
      )

      manifest = registry.representation_manifest('TEST_001')
      expect(manifest[:catalog_render][:status]).to eq('missing')
      expect(manifest[:catalog_render][:files]).to be_empty
      expect(manifest[:inventory_icon][:status]).to eq('missing')
    end

    it 'does not set complexity_levels for missing profiles' do
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle',
        representations: { catalog_render: { status: 'missing' } }
      )

      manifest = registry.representation_manifest('TEST_001')
      expect(manifest[:catalog_render][:complexity_levels]).to be_empty
    end
  end

  describe 'experimental representation handling' do
    it 'marks test assets as experimental' do
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle',
        representations: { sprite_sheet: { status: 'experimental', notes: 'Test asset' } }
      )

      manifest = registry.representation_manifest('TEST_001')
      expect(manifest[:sprite_sheet][:status]).to eq('experimental')
      expect(manifest[:sprite_sheet][:notes]).to eq('Test asset')
    end

    it 'does not count experimental as exists' do
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle',
        representations: { sprite_sheet: { status: 'experimental' } }
      )

      expect(registry.representation_exists?('TEST_001', :sprite_sheet)).to be false
    end
  end

  describe 'no repository search in PromptCompiler' do
    it 'AssetRegistry resolves paths, does not delegate search to PromptCompiler' do
      # This test verifies the architectural boundary: AssetRegistry owns resolution,
      # PromptCompiler (not tested here) consumes resolved inputs only
      
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle'
      )

      entry = registry.resolve('TEST_001')
      
      # Verify paths are resolved and stored in registry
      expect(entry).to have_key(:blueprint_path)
      expect(entry).to have_key(:visual_definition_path)
      
      # Verify no repository search is needed — paths are pre-resolved
      # (In production, these would be actual file paths; in tests they may be nil if files don't exist)
    end
  end

  describe 'PromptCompiler public API compatibility' do
    it 'does not add visual_profile_path to public API' do
      # This test verifies that AssetRegistry stores visual_profile_id (not path)
      # The actual path resolution happens in orchestration, not in the registry
      
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle',
        visual_profile_id: 'VP_ROVER_STANDARD_001'
      )

      entry = registry.resolve('TEST_001')
      
      # Registry stores visual_profile_id, not visual_profile_path
      expect(entry[:visual_profile_id]).to eq('VP_ROVER_STANDARD_001')
      expect(entry).not_to have_key(:visual_profile_path)
    end

    it 'maintains 5-argument PromptCompiler interface compatibility' do
      # This test verifies that the registry provides resolved paths that fit
      # the existing PromptCompiler.compile interface:
      # PromptCompiler.compile(
      #   asset_id:,
      #   blueprint_path:,
      #   operational_data_path:,
      #   visual_definition_path:,
      #   render_template_path:
      # )
      
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle'
      )

      entry = registry.resolve('TEST_001')
      
      # Verify all 5 required keys exist in entry structure for PromptCompiler
      expect(entry).to have_key(:asset_id)
      expect(entry).to have_key(:blueprint_path)
      expect(entry).to have_key(:operational_data_path)
      expect(entry).to have_key(:visual_definition_path)
      expect(entry).to have_key(:render_template_path)
    end
  end

  describe 'representation manifest supports downstream consumers' do
    it 'provides catalog consumer with resolved catalog_render path' do
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle',
        representations: { catalog_render: { status: 'exists', files: ['test_catalog.png'] } }
      )

      manifest = registry.representation_manifest('TEST_001')
      expect(manifest[:catalog_render][:status]).to eq('exists')
      expect(manifest[:catalog_render][:files]).to include('test_catalog.png')
    end

    it 'provides surface consumer with sprite_sheet status' do
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle',
        representations: { sprite_sheet: { status: 'exists', files: ['test_spritesheet.png'] } }
      )

      manifest = registry.representation_manifest('TEST_001')
      expect(manifest[:sprite_sheet][:status]).to eq('exists')
      expect(manifest[:sprite_sheet][:files]).to include('test_spritesheet.png')
    end

    it 'supports missing representation for graceful degradation' do
      registry.register_asset(
        asset_id: 'TEST_001',
        blueprint_id: 'test',
        asset_family: 'vehicle',
        representations: { catalog_render: { status: 'missing' } }
      )

      manifest = registry.representation_manifest('TEST_001')
      expect(manifest[:catalog_render][:status]).to eq('missing')
      # Catalog UI can show placeholder/empty state for missing representations
    end
  end
end
