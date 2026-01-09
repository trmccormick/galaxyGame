# spec/integration/shell_printing_game_loop_spec.rb
require 'rails_helper'

RSpec.describe 'Shell Printing Game Loop Integration', type: :integration do
  let!(:gcc) do
    Financial::Currency.find_or_create_by!(symbol: 'GCC') do |c|
      c.name = 'Galactic Crypto Currency'
      c.is_system_currency = true
      c.precision = 8
    end
  end

  let!(:celestial_body) { create(:large_moon, :luna) }
  let(:location) do
    create(:celestial_location,
      name: "Shackleton Crater Base",
      celestial_body: celestial_body
    )
  end
  let!(:player) { create(:player, active_location: "Shackleton Crater Base") }
  let!(:settlement) do
    create(:base_settlement,
      owner: player,
      location: location
    ).tap do |s|
      s.inventory.update(capacity: 10000) # Ensure inventory can store items
    end
  end
  
  let(:printer_unit) do
    create(:base_unit,
      owner: settlement,
      attachable: settlement,
      operational_data: {
        'processing_capabilities' => {
          'geosphere_processing' => {
            'enabled' => true,
            'types' => ['regolith'],
            'efficiency' => 0.85
          }
        },
        'component_production' => {
          'production_rate_multiplier' => 1.2
        }
      }
    )
  end

  let(:inflatable_tank) do
    create(:base_unit,
      owner: settlement,
      attachable: settlement,
      unit_type: 'inflatable_cryo_tank',
      operational_data: {
        'capacity' => 5000,
        'current_level' => 0,
        'deployed' => true,
        'operational' => true
      }
    )
  end

  let(:game_state) { GameState.first || GameState.create!(year: 2200, day: 1) }
  let(:game) { Game.new(game_state: game_state) }

  before do
    # Stub blueprint lookup
    allow_any_instance_of(Lookup::BlueprintLookupService)
      .to receive(:find_blueprint)
      .with('inflatable_cryo_tank')
      .and_return({
        'id' => 'inflatable_cryo_tank',
        'name' => 'Inflatable Cryogenic Tank',
        'shell_requirements' => {
          'material_requirements' => [
            {
              'material' => 'inert_regolith_waste',
              'quantity' => 1400,
              'unit' => 'kg'
            },
            {
              'material' => '3D-Printed I-Beam Mk1',
              'quantity' => 5,
              'unit' => 'units'
            }
          ],
          'printing_time_hours' => 10.0
        }
      })

    # Stub item lookups
    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('inert_regolith_waste')
      .and_return({
        'id' => 'inert_regolith_waste',
        'name' => 'Inert Regolith Waste',
        'type' => 'processed_material'
      })

    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('3D-Printed I-Beam Mk1')
      .and_return({
        'id' => '3d_printed_ibeam_mk1',
        'name' => '3D-Printed I-Beam Mk1',
        'type' => 'component'
      })

    # Add materials to inventory
    Item.create!(name: 'inert_regolith_waste', amount: 2000, owner: player, inventory: settlement.inventory, metadata: {'composition' => { 'SiO2' => 43.0, 'Al2O3' => 24.0 }}, storage_method: 'bulk_storage')
    Item.create!(name: '3D-Printed I-Beam Mk1', amount: 10, owner: player, inventory: settlement.inventory, metadata: {}, storage_method: 'bulk_storage')

    # Force reload to ensure items are persisted and visible
    settlement.reload
    settlement.inventory.reload

    # Debug: Check what items are actually in inventory
    # puts "=== DEBUG: Inventory after setup ==="
    # puts "Settlement ID: #{settlement.id}"
    # puts "Inventory ID: #{settlement.inventory.id}"
    # puts "Inventory persisted: #{settlement.inventory.persisted?}"
    # puts "All items in DB: #{Item.all.pluck(:name, :amount, :inventory_id)}"
    # puts "Items via association: #{settlement.inventory.items.pluck(:name, :amount, :owner_id, :inventory_id)}"
    # puts "All items in DB for inventory #{settlement.inventory.id}: #{Item.where(inventory_id: settlement.inventory.id).pluck(:name, :amount)}"
    # puts "Total inert_regolith_waste: #{settlement.inventory.current_storage_of('inert_regolith_waste')}kg"
    # puts "=== END DEBUG ==="
  end

  describe 'full shell printing cycle' do
    it 'encloses inflatable tank through game loop progression' do
      # 1. Create shell printing job
      service = Manufacturing::ShellPrintingService.new(settlement)
      job = service.enclose_inflatable(inflatable_tank, printer_unit)
      
      expect(job.status).to eq('pending')
      expect(job.production_time_hours).to be_within(0.01).of(8.33) # 10.0 / 1.2 multiplier
      
      # 2. Tank should not be enclosed yet
      expect(inflatable_tank.operational_data['enclosed']).to be_nil
      
      # 3. Start the job
      job.start!
      expect(job.status).to eq('in_progress')
      
      # 4. Advance game by 0.5 days (12 hours) - should complete the ~8.3-hour job
      game.advance_by_days(0.5)
      
      # 5. Verify job completed
      job.reload
      expect(job.status).to eq('completed')
      
      # 6. Verify tank is now enclosed
      inflatable_tank.reload
      expect(inflatable_tank.operational_data['enclosed']).to be true
      expect(inflatable_tank.operational_data['shell_printed_at']).to be_present
      expect(inflatable_tank.operational_data['shell_materials']).to be_present
    end

    it 'tracks material composition in shell metadata' do
      service = Manufacturing::ShellPrintingService.new(settlement)
      job = service.enclose_inflatable(inflatable_tank, printer_unit)
      job.start!
      
      game.advance_by_days(0.5)
      
      inflatable_tank.reload
      shell_materials = inflatable_tank.operational_data['shell_materials']
      
      expect(shell_materials['inert_regolith_waste']['amount']).to eq(1400)
      expect(shell_materials['inert_regolith_waste']['composition']).to include(
        'SiO2' => 43.0,
        'Al2O3' => 24.0
      )
    end
  end
end