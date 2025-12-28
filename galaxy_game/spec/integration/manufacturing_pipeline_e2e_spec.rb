# spec/integration/manufacturing_pipeline_e2e_spec.rb
require 'rails_helper'

RSpec.describe 'Manufacturing Pipeline End-to-End', type: :integration do
  let!(:gcc) do
    Financial::Currency.find_or_create_by!(symbol: 'GCC') do |c|
      c.name = 'Galactic Crypto Currency'
      c.is_system_currency = true
      c.precision = 8
    end
  end

  let!(:luna) { create(:large_moon, :luna) }

  let(:location) do
    create(:celestial_location,
      name: "Shackleton Crater Base",
      celestial_body: luna
    )
  end

  let(:player) { create(:player, active_location: "Shackleton Crater Base") }
  
  let(:settlement) do
    create(:base_settlement,
      owner: player,
      location: location
    )
  end

  # Processing units
  let(:teu_unit) do
    create(:base_unit,
      owner: settlement,
      attachable: settlement,
      operational_data: {
        'geosphere_processing' => {
          'processes' => ['thermal_extraction'],
          'input_materials' => ['raw_regolith'],
          'production_rate_multiplier' => 1.0
        }
      }
    )
  end

  let(:pve_unit) do
    create(:base_unit,
      owner: settlement,
      attachable: settlement,
      operational_data: {
        'geosphere_processing' => {
          'processes' => ['volatiles_extraction'],
          'input_materials' => ['processed_regolith'],
          'production_rate_multiplier' => 1.0
        }
      }
    )
  end

  # Manufacturing units
  let(:printer_unit) do
    create(:base_unit,
      owner: settlement,
      attachable: settlement,
      operational_data: {
        'component_production' => {
          'categories' => ['structural'],
          'production_rate_multiplier' => 1.0
        }
      }
    )
  end

  let(:shell_printer_unit) do
    create(:base_unit,
      owner: settlement,
      attachable: settlement,
      operational_data: {
        'geosphere_processing' => {
          'processes' => ['regolith'],
          'material_types' => ['regolith'],
          'production_rate_multiplier' => 1.0
        }
      }
    )
  end

  # Inflatable tank to be enclosed
  let(:inflatable_tank) do
    create(:base_unit,
      name: 'Inflatable Cryo Tank',
      unit_type: 'inflatable_cryo_tank',
      owner: settlement,
      attachable: settlement,
      operational_data: {
        'deployed' => true,
        'operational' => true,
        'shell_requirements' => {
          'material_requirements' => [
            { 'material' => 'inert_regolith_waste', 'amount' => 1400 },
            { 'material' => '3D-Printed I-Beam Mk1', 'amount' => 5 }
          ],
          'printing_time_hours' => 48.0,
          'shell_thickness_cm' => 30.0,
          'protection_rating' => 'high'
        }
      }
    )
  end

  let(:game_state) { GameState.first || GameState.create!(year: 2200, day: 1) }
  let(:game) { Game.new(game_state: game_state) }

  before do
    # Stub all item lookups needed for the pipeline
    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .and_call_original

    # Raw materials
    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('raw_regolith')
      .and_return({
        'id' => 'raw_regolith',
        'name' => 'Raw Regolith',
        'type' => 'raw_material',
        'physical_properties' => { 'mass_kg' => 1.0, 'volume_m3' => 0.001 }
      })

    # Processed materials
    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('processed_regolith')
      .and_return({
        'id' => 'processed_regolith',
        'name' => 'Processed Regolith',
        'type' => 'processed_material',
        'physical_properties' => { 'mass_kg' => 1.0, 'volume_m3' => 0.001 }
      })

    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('inert_regolith_waste')
      .and_return({
        'id' => 'inert_regolith_waste',
        'name' => 'Inert Regolith Waste',
        'type' => 'processed_material',
        'physical_properties' => { 'mass_kg' => 1.0, 'volume_m3' => 0.001 }
      })

    # Volatiles
    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('water')
      .and_return({
        'id' => 'water',
        'name' => 'Water',
        'type' => 'volatile',
        'physical_properties' => { 'mass_kg' => 1.0, 'volume_m3' => 0.001 }
      })

    ['hydrogen', 'carbon_monoxide', 'helium_3', 'neon'].each do |gas|
      allow_any_instance_of(Lookup::ItemLookupService)
        .to receive(:find_item)
        .with(gas)
        .and_return({
          'id' => gas,
          'name' => gas.titleize,
          'type' => 'gas',
          'physical_properties' => { 'mass_kg' => 0.1, 'volume_m3' => 0.01 }
        })
    end

    # Components
    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('3D-Printed I-Beam Mk1')
      .and_return({
        'id' => '3d_printed_ibeam_mk1',
        'name' => '3D-Printed I-Beam Mk1',
        'type' => 'component',
        'physical_properties' => { 'mass_kg' => 98.0, 'volume_m3' => 0.5 }
      })

    # Waste products
    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('manufacturing_dust')
      .and_return({
        'id' => 'manufacturing_dust',
        'name' => 'Manufacturing Dust',
        'type' => 'waste_product',
        'physical_properties' => { 'mass_kg' => 0.1, 'volume_m3' => 0.001 }
      })

    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('offgas_volatiles')
      .and_return({
        'id' => 'offgas_volatiles',
        'name' => 'Offgas Volatiles',
        'type' => 'waste_product',
        'physical_properties' => { 'mass_kg' => 0.05, 'volume_m3' => 0.002 }
      })

    # Ensure settlement has surface storage
    unless settlement.inventory.surface_storage
      Storage::SurfaceStorage.create!(
        inventory: settlement.inventory,
        settlement_id: settlement.id,
        celestial_body: luna,
        item_type: 'Solid'
      )
    end
  end

  describe 'complete ISRU to enclosed tank pipeline' do
    it 'processes raw regolith through all stages to produce an enclosed tank' do
      # ================================================================
      # STAGE 0: Initial Setup
      # ================================================================
      puts "\n=== STAGE 0: Initial Setup ==="
      
      # Add 2000kg raw regolith to surface storage
      surface_storage = settlement.inventory.surface_storage
      surface_storage.add_pile(
        material_name: 'raw_regolith',
        amount: 2000.0,
        source_unit: 'harvester_rover'
      )
      settlement.inventory.add_item('raw_regolith', 2000.0, player, {
        'source_body' => luna.identifier,
        'storage_location' => 'surface_pile'
      })

      initial_raw = settlement.inventory.items.find_by(name: 'raw_regolith')
      expect(initial_raw.amount).to eq(2000.0)
      puts "✓ Staged 2000kg raw regolith"

      # ================================================================
      # STAGE 1: Thermal Extraction (TEU)
      # ================================================================
      puts "\n=== STAGE 1: Thermal Extraction Unit (TEU) ==="
      
      processing_service = Manufacturing::MaterialProcessingService.new(settlement)
      
      # Process 1000kg raw regolith → processed regolith
      teu_job = processing_service.thermal_extraction(1000.0, teu_unit)
      
      expect(teu_job).to be_present
      expect(teu_job.status).to eq('pending')
      expect(teu_job.input_material).to eq('raw_regolith')
      expect(teu_job.input_amount).to eq(1000.0)
      puts "✓ Created TEU job for 1000kg raw regolith"

      # Start job and advance time
      teu_job.start!
      expect(teu_job.status).to eq('in_progress')
      
      # Advance game time to complete TEU job
      game.advance_by_days(1)
      
      teu_job.reload
      expect(teu_job.status).to eq('completed')
      puts "✓ TEU job completed"

      # Verify processed regolith produced (99.5% yield)
      processed = settlement.inventory.items.find_by(name: 'processed_regolith')
      expect(processed).to be_present
      expect(processed.amount).to be >= 990.0 # ~99.5% yield
      puts "✓ Produced #{processed.amount}kg processed regolith"

      # ================================================================
      # STAGE 2: Volatiles Extraction (PVE)
      # ================================================================
      puts "\n=== STAGE 2: Plasma Volatiles Extractor (PVE) ==="
      
      # Process all processed regolith → inert waste + volatiles
      pve_job = processing_service.volatiles_extraction(processed.amount, pve_unit)
      
      expect(pve_job).to be_present
      expect(pve_job.status).to eq('pending')
      puts "✓ Created PVE job for #{processed.amount}kg processed regolith"

      # Start job and advance time
      pve_job.start!
      
      # Advance game time to complete PVE job
      game.advance_by_days(1)
      
      pve_job.reload
      expect(pve_job.status).to eq('completed')
      puts "✓ PVE job completed"

      # Verify outputs
      inert_waste = settlement.inventory.items.find_by(name: 'inert_regolith_waste')
      expect(inert_waste).to be_present
      expect(inert_waste.amount).to be >= 900.0 # ~97% yield
      puts "✓ Produced #{inert_waste.amount}kg inert waste"

      water = settlement.inventory.items.find_by(name: 'water')
      expect(water).to be_present
      expect(water.amount).to be > 0
      puts "✓ Extracted #{water.amount}kg water"

      # Check for gases
      gases = ['hydrogen', 'carbon_monoxide', 'helium_3', 'neon']
      gases.each do |gas|
        gas_item = settlement.inventory.items.find_by(name: gas)
        if gas_item
          puts "✓ Extracted #{gas_item.amount}kg #{gas}"
        end
      end

      # ================================================================
      # STAGE 3: Component Production (I-Beams)
      # ================================================================
      puts "\n=== STAGE 3: Component Production (I-Beams) ==="
      
      # Need to add depleted_regolith for component production
      # (The component service expects 'depleted_regolith' as input material)
      settlement.inventory.add_item('depleted_regolith', inert_waste.amount, player, {
        'source_process' => 'volatiles_extraction',
        'composition' => inert_waste.metadata['composition']
      })
      
      component_service = Manufacturing::ComponentProductionService.new(settlement)
      
      # Produce 5 I-beams (needs ~75kg each = 375kg total)
      ibeam_job = component_service.produce_component(
        '3d_printed_ibeam_mk1',
        5,
        printer_unit
      )
      
      expect(ibeam_job).to be_present
      expect(ibeam_job.status).to eq('pending')
      expect(ibeam_job.quantity).to eq(5)
      puts "✓ Created component production job for 5 I-beams"

      # Start job and advance time
      ibeam_job.start!
      
      # Advance game time to complete component production
      game.advance_by_days(1)
      
      ibeam_job.reload
      expect(ibeam_job.status).to eq('completed')
      puts "✓ Component production completed"

      # Verify I-beams produced
      ibeams = settlement.inventory.items.find_by(name: '3D-Printed I-Beam Mk1')
      expect(ibeams).to be_present
      expect(ibeams.amount).to eq(5)
      puts "✓ Produced 5 I-beams"

      # Verify waste products
      mfg_dust = settlement.inventory.items.find_by(name: 'manufacturing_dust')
      if mfg_dust
        puts "✓ Generated #{mfg_dust.amount}kg manufacturing dust"
      end

      offgas = settlement.inventory.items.find_by(name: 'offgas_volatiles')
      if offgas
        puts "✓ Generated #{offgas.amount}kg offgas volatiles"
      end

      # ================================================================
      # STAGE 4: Shell Printing (Tank Enclosure)
      # ================================================================
      puts "\n=== STAGE 4: Shell Printing (Tank Enclosure) ==="
      
      # Ensure we have enough inert waste for shell
      remaining_inert = settlement.inventory.items.find_by(name: 'inert_regolith_waste')
      if !remaining_inert || remaining_inert.amount < 1400
        needed = 1400 - (remaining_inert&.amount || 0)
        settlement.inventory.add_item('inert_regolith_waste', needed, player)
        puts "✓ Added #{needed}kg additional inert waste for shell"
      end

      shell_service = Manufacturing::ShellPrintingService.new(settlement)
      
      # Print shell for inflatable tank
      shell_job = shell_service.print_shell(
        inflatable_tank,
        shell_printer_unit
      )
      
      expect(shell_job).to be_present
      expect(shell_job.status).to eq('pending')
      expect(shell_job.inflatable_tank).to eq(inflatable_tank)
      puts "✓ Created shell printing job for #{inflatable_tank.name}"

      # Start job and advance time
      shell_job.start!
      
      # Advance game time to complete shell printing (48 hours)
      game.advance_by_days(2)
      
      shell_job.reload
      expect(shell_job.status).to eq('completed')
      puts "✓ Shell printing completed"

      # Verify tank is now enclosed
      inflatable_tank.reload
      expect(inflatable_tank.operational_data['enclosed']).to eq(true)
      expect(inflatable_tank.operational_data['shell_materials']).to be_present
      puts "✓ Tank is now enclosed with protective shell"
      puts "✓ Shell materials tracked in operational_data"

      # ================================================================
      # FINAL VERIFICATION
      # ================================================================
      puts "\n=== FINAL VERIFICATION ==="
      
      # Verify complete pipeline worked
      expect(inflatable_tank.operational_data['enclosed']).to eq(true)
      expect(ibeams.amount).to eq(5)
      expect(water.amount).to be > 0
      
      puts "\n✅ COMPLETE PIPELINE SUCCESS:"
      puts "  Raw Regolith (1000kg)"
      puts "    ↓ TEU Processing"
      puts "  Processed Regolith (~995kg)"
      puts "    ↓ PVE Processing"
      puts "  Inert Waste + Water + Gases"
      puts "    ↓ Component Production"
      puts "  5x I-Beams + Waste Products"
      puts "    ↓ Shell Printing"
      puts "  Enclosed Tank (Ready for Fuel Storage)"
      
      # Print final inventory summary
      puts "\n📦 Final Inventory:"
      settlement.inventory.items.order(:name).each do |item|
        puts "  - #{item.name}: #{item.amount}"
      end
    end
  end

  describe 'pipeline with multiple batches' do
    it 'can process multiple batches concurrently' do
      # Add raw materials
      surface_storage = settlement.inventory.surface_storage
      surface_storage.add_pile(
        material_name: 'raw_regolith',
        amount: 3000.0,
        source_unit: 'harvester_rover'
      )
      settlement.inventory.add_item('raw_regolith', 3000.0, player)

      processing_service = Manufacturing::MaterialProcessingService.new(settlement)
      
      # Create multiple TEU jobs
      job1 = processing_service.thermal_extraction(1000.0, teu_unit)
      job2 = processing_service.thermal_extraction(1000.0, teu_unit)

      job1.start!
      job2.start!

      # Both should be in progress
      expect(job1.status).to eq('in_progress')
      expect(job2.status).to eq('in_progress')

      # Advance time to complete both
      game.advance_by_days(1)

      # Both should complete
      expect(job1.reload.status).to eq('completed')
      expect(job2.reload.status).to eq('completed')

      # Should have ~2000kg processed regolith
      processed = settlement.inventory.items.find_by(name: 'processed_regolith')
      expect(processed.amount).to be >= 1980.0
    end
  end

  describe 'material tracking through pipeline' do
    it 'preserves composition metadata through processing chain' do
      # Add raw regolith with composition
      settlement.inventory.add_item('raw_regolith', 1000.0, player, {
        'source_body' => luna.identifier,
        'composition' => {
          'SiO2' => 43.0,
          'Al2O3' => 24.0,
          'FeO' => 15.0
        }
      })

      processing_service = Manufacturing::MaterialProcessingService.new(settlement)
      
      # TEU processing
      teu_job = processing_service.thermal_extraction(1000.0, teu_unit)
      teu_job.start!
      game.advance_by_days(1)

      # Check processed regolith has composition
      processed = settlement.inventory.items.find_by(name: 'processed_regolith')
      expect(processed.metadata['composition']).to be_present
      expect(processed.metadata['source_materials']).to include('raw_regolith')

      # PVE processing
      pve_job = processing_service.volatiles_extraction(processed.amount, pve_unit)
      pve_job.start!
      game.advance_by_days(1)

      # Check inert waste has composition traced back
      inert = settlement.inventory.items.find_by(name: 'inert_regolith_waste')
      expect(inert.metadata['composition']).to be_present
      expect(inert.metadata['source_materials']).to include('processed_regolith')
    end
  end
end