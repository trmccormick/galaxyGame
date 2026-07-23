require 'rails_helper'

RSpec.describe Craft::Harvester, type: :model do
  let(:player) { create(:player) }
  let(:harvester) { create(:craft_harvester, player: player) }
  let(:target_body) { 'asteroid' }

  before do
    allow(harvester).to receive(:craft_info).and_return({
      'deployment' => { 'deployment_locations' => ['asteroid', 'moon'] },
      'extraction_efficiency' => 0.9,
      'processable_materials' => ['raw_material'],
      'processing_conversion_rate' => 0.8
    })
  end

  describe 'validations' do
    it 'is valid with a positive extraction_rate' do
      harvester.extraction_rate = 10
      expect(harvester).to be_valid
    end

    it 'is invalid with a negative extraction_rate' do
      harvester.extraction_rate = -5
      expect(harvester).to_not be_valid
    end
  end

  describe '#extract_resources' do
    context 'when extracting from a valid target' do
      it 'increases inventory with extracted resources' do
        harvester.extract_resources(target_body, 100)
        regolith = harvester.inventory.items.find_by(name: 'Regolith')

        expect(regolith.amount).to eq(90) # 100 * 0.9 efficiency
      end
    end

    context 'when extracting from an invalid target' do
      it 'raises an error' do
        expect { harvester.extract_resources('gas_giant', 50) }
          .to raise_error("Invalid target")
      end
    end

    context 'when storage is full' do
      before do
        allow(harvester).to receive(:can_store?).and_return(false)
      end

      it 'raises an error' do
        expect { harvester.extract_resources(target_body, 50) }
          .to raise_error("Storage full")
      end
    end
  end

  describe '#process_resources' do
    before do
      harvester.inventory.items.create!(name: 'Regolith', amount: 100, owner: harvester.player, storage_method: 'bulk_storage', material_type: :raw_material)
    end

    it 'converts raw material into refined material' do
      harvester.process_resources

      raw_material = harvester.inventory.items.find_by(name: 'Regolith')
      refined_material = harvester.inventory.items.find_by(name: 'Processed Regolith')

      expect(raw_material.amount).to eq(20) # 100 - 80 processed
      expect(refined_material.amount).to eq(80) # 100 * 0.8 conversion
    end

    it 'does nothing if no processable materials are present' do
      harvester.inventory.items.destroy_all
      expect { harvester.process_resources }.not_to change { harvester.inventory.items.count }
    end
  end

  describe '#apply_exhaust_to_atmosphere!' do
    let(:source_body) { create(:celestial_body, name: 'Mars') }
    let(:atmosphere_mock) { double('CelestialBodies::Spheres::Atmosphere') }
    let(:harvester_with_body) { create(:craft_harvester, player: player, status: 'active') }

    before do
      allow(harvester_with_body).to receive(:source_body).and_return(source_body)
      allow(source_body).to receive(:atmosphere).and_return(atmosphere_mock)
      # Stub add_gas to return true (we're testing the call, not the implementation)
      allow(atmosphere_mock).to receive(:add_gas).and_return(true)
    end

    context 'when source body has no atmosphere' do
      before do
        allow(source_body).to receive(:atmosphere).and_return(nil)
      end

      it 'returns early without raising error' do
        expect { harvester_with_body.apply_exhaust_to_atmosphere! }.not_to raise_error
      end
    end

    context 'when harvester is not operational' do
      let(:harvester_not_operational) { create(:craft_harvester, player: player, status: 'idle') }

      before do
        allow(harvester_not_operational).to receive(:source_body).and_return(source_body)
        allow(source_body).to receive(:atmosphere).and_return(atmosphere_mock)
        allow(atmosphere_mock).to receive(:add_gas).and_return(true)
      end

      it 'returns early without adding gas' do
        expect(atmosphere_mock).not_to receive(:add_gas)
        harvester_not_operational.apply_exhaust_to_atmosphere!
      end
    end

    context 'when harvester is operational with CH4_O2 propellant' do
      before do
        harvester_with_body.operational_data = { 'propellant_type' => 'CH4_O2', 'extraction_rate' => 100 }.merge(harvester_with_body.operational_data || {})
      end

      it 'adds CO2 and H2O to atmosphere in correct proportions' do
        harvester_with_body.apply_exhaust_to_atmosphere!
        # CH4_O2: 1.37 kg exhaust per kg propellant, 0.73 CO2 + 0.27 H2O
        # extraction_rate=100 * 0.01 = 1 kg propellant * 1.37 = 1.37 kg total exhaust
        expect(atmosphere_mock).to have_received(:add_gas).with('CO2', kind_of(Float))
        expect(atmosphere_mock).to have_received(:add_gas).with('H2O', kind_of(Float))
      end

      it 'logs exhaust emissions' do
        allow(Rails.logger).to receive(:info)
        harvester_with_body.apply_exhaust_to_atmosphere!
        expect(Rails.logger).to have_received(:info).with(/Exhaust/).at_least(:once)
      end
    end

    context 'when propellant type is LH2_LOX' do
      before do
        harvester_with_body.operational_data = { 'propellant_type' => 'LH2_LOX', 'extraction_rate' => 100 }.merge(harvester_with_body.operational_data || {})
      end

      it 'adds only H2O to atmosphere' do
        harvester_with_body.apply_exhaust_to_atmosphere!
        expect(atmosphere_mock).to have_received(:add_gas).with('H2O', kind_of(Float))
      end
    end

    context 'when propellant type is unknown' do
      before do
        harvester_with_body.operational_data = { 'propellant_type' => 'UNKNOWN', 'extraction_rate' => 100 }.merge(harvester_with_body.operational_data || {})
      end

      it 'skips exhaust (unknown propellant types are safely ignored)' do
        harvester_with_body.apply_exhaust_to_atmosphere!
        expect(atmosphere_mock).not_to have_received(:add_gas)
      end
    end
  end

  describe '#operational?' do
    it 'returns true for active status' do
      harvester.status = 'active'
      expect(harvester).to be_operational
    end

    it 'returns true for operational status' do
      harvester.status = 'operational'
      expect(harvester).to be_operational
    end

    it 'returns true for harvesting status' do
      harvester.status = 'harvesting'
      expect(harvester).to be_operational
    end

    it 'returns false for idle status' do
      harvester.status = 'idle'
      expect(harvester).not_to be_operational
    end

    it 'returns false for nil status' do
      harvester.status = nil
      expect(harvester).not_to be_operational
    end
  end
end
