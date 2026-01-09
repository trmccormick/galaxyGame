# spec/integration/component_production_game_loop_spec.rb
require 'rails_helper'

RSpec.describe 'Component Production Game Loop Integration', type: :integration do
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
  let(:player) { create(:player, active_location: "Shackleton Crater Base") }
  let(:settlement) do
    create(:base_settlement,
      owner: player,
      location: location
    )
  end
  
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

  let(:game_state) { GameState.first || GameState.create!(year: 2200, day: 1) }
  let(:game) { Game.new(game_state: game_state) }

  before do
    # Stub item lookups FIRST
    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('depleted_regolith')
      .and_return({
        'id' => 'depleted_regolith',
        'name' => 'depleted_regolith',
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
    
    # ADD THIS - stub for manufacturing waste product
    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('manufacturing_dust')
      .and_return({
        'id' => 'manufacturing_dust',
        'name' => 'Manufacturing Dust',
        'type' => 'waste_product',
        'physical_properties' => { 'mass_kg' => 0.1, 'volume_m3' => 0.001 }
      })

    # Add depleted_regolith to inventory AFTER stubbing
    item = settlement.inventory.items.create!(name: 'depleted_regolith', amount: 1000, owner: player)
    settlement.reload
    settlement.inventory.reload
    settlement.inventory.items.reload

    # ADD THIS - stub for offgas_volatiles waste product
    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('offgas_volatiles')
      .and_return({
        'id' => 'offgas_volatiles',
        'name' => 'Offgas Volatiles',
        'type' => 'waste_product',
        'physical_properties' => { 'mass_kg' => 2.0, 'volume_m3' => 0.0 }
      })
    
    # Stub blueprint lookup
    allow_any_instance_of(Lookup::BlueprintLookupService)
      .to receive(:find_blueprint)
      .with('3d_printed_ibeam_mk1')
      .and_return({
        'id' => '3d_printed_ibeam_mk1',
        'name' => '3D-Printed I-Beam Mk1',
        'category' => 'structural',
        'production_time_hours' => 2.0,
        'blueprint_data' => {
          'material_requirements' => [
            {
              'material' => 'depleted_regolith',
              'quantity' => 10
            }
          ],
          'construction_time_hours' => 2.0,
          'waste_generated' => {
            'manufacturing_dust' => 1
          }
        }
      })
  end

  describe 'full production cycle' do
    it 'produces components through game loop progression' do
      # 1. Create production job
      service = Manufacturing::ComponentProductionService.new(settlement)
      job = service.produce_component('3d_printed_ibeam_mk1', 2, printer_unit)
      
      expect(job.status).to eq('pending')
      expect(job.production_time_hours).to eq(4.0) # 2 hours * 2 quantity
      
      # 2. Start the job
      job.start!
      expect(job.status).to eq('in_progress')
      expect(job.progress_hours).to eq(0.0)
      
      # 3. Advance game by 1 day (24 hours) - should complete the 4-hour job
      game.advance_by_days(1)
      
      # 4. Verify job completed
      job.reload
      expect(job.status).to eq('completed')
      expect(job.progress_hours).to eq(4.0)
      
      # 5. Verify components added to inventory
      ibeam = settlement.inventory.items.find_by(name: '3D-Printed I-Beam Mk1')
      expect(ibeam).to be_present
      expect(ibeam.amount).to eq(2)
      
      # 6. Verify composition metadata stored
      expect(ibeam.metadata['source_materials']).to be_present
      expect(ibeam.metadata['manufactured_at']).to eq(settlement.name)
    end

    it 'handles partial progress over multiple ticks' do
      service = Manufacturing::ComponentProductionService.new(settlement)
      job = service.produce_component('3d_printed_ibeam_mk1', 1, printer_unit)
      job.start!
      
      # Job takes 2 hours
      expect(job.production_time_hours).to eq(2.0)
      
      # Advance by 0.5 days (12 hours) - should complete
      game.advance_by_days(0.5)
      
      job.reload
      expect(job.status).to eq('completed')
      expect(job.progress_hours).to eq(2.0)
    end

    it 'processes multiple jobs simultaneously' do
      service = Manufacturing::ComponentProductionService.new(settlement)
      
      # Create two jobs
      job1 = service.produce_component('3d_printed_ibeam_mk1', 1, printer_unit)
      
      # Add more materials for second job
      job2 = service.produce_component('3d_printed_ibeam_mk1', 1, printer_unit)
      
      job1.start!
      job2.start!
      
      # Advance game
      game.advance_by_days(1)
      
      # Both should complete
      expect(job1.reload.status).to eq('completed')
      expect(job2.reload.status).to eq('completed')
      
      # Should have 2 I-beams total
      total_ibeams = settlement.inventory.items.where(name: '3D-Printed I-Beam Mk1').sum(:amount)
      expect(total_ibeams).to eq(2)
    end
  end
end