# spec/services/manufacturing/component_production_integration_spec.rb
require 'rails_helper'

RSpec.describe 'Component Production Integration', type: :integration do
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
  
  let(:service) { Manufacturing::ComponentProductionService.new(settlement) }

  describe 'with real blueprint files' do
    it 'finds the 3d_printed_ibeam_mk1 blueprint' do
      lookup = Lookup::BlueprintLookupService.new
      blueprint = lookup.find_blueprint('3d_printed_ibeam_mk1')
      
      expect(blueprint).to be_present
      expect(blueprint['id']).to eq('3d_printed_ibeam_mk1')
      expect(blueprint['template']).to eq('component_blueprint')
    end

    context 'producing mk1 I-beams (bootstrap version)' do
      before do
        # Add storage capacity to the settlement
        storage_unit = create(:base_unit,
          attachable: settlement,
          operational_data: {
            'storage' => {
              'capacity' => 1000,
              'type' => 'general'
            }
          }
        )
        
        # Create printer unit for this context
        @printer_unit = create(:base_unit,
          owner: settlement,
          attachable: settlement,
          operational_data: {
            'component_production' => {
              'categories' => ['structural'],
              'production_rate_multiplier' => 1.0
            }
          }
        )
        
        # Add depleted_regolith to inventory (the mk1 only needs this!)
        settlement.inventory.add_item('depleted_regolith', 200, player, {
          'composition' => { 'SiO2' => 43.0, 'Al2O3' => 24.0 }
        })
        
        # Stub item lookup for depleted_regolith
        allow_any_instance_of(Lookup::ItemLookupService)
          .to receive(:find_item)
          .with('depleted_regolith')
          .and_return({
            'id' => 'depleted_regolith',
            'name' => 'Depleted Regolith',
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
      end

      it 'creates a production job using real blueprint' do
        expect {
          service.produce_component('3d_printed_ibeam_mk1', 2, @printer_unit)
        }.to change { ComponentProductionJob.count }.by(1)

        job = ComponentProductionJob.last
        expect(job.component_blueprint_id).to eq('3d_printed_ibeam_mk1')
        expect(job.component_name).to eq('3D-Printed I-Beam Mk1')
        expect(job.quantity).to eq(2)
      end

      it 'consumes depleted_regolith from inventory' do
        service.produce_component('3d_printed_ibeam_mk1', 1, @printer_unit)
        
        depleted_regolith = settlement.inventory.items.find_by(name: 'depleted_regolith')
        expect(depleted_regolith.amount).to eq(125) # 200 - 75
      end
    end
  end
end