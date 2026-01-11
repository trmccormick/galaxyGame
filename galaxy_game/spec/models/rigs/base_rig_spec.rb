require 'rails_helper'

RSpec.describe Rigs::BaseRig, type: :model do
    describe 'detach/destroy behavior' do
      let!(:rig) { create(:base_rig, attachable: base_unit) }

      it 'destroys the rig when removed from attachable' do
        expect { rig.remove_from }.to change { Rigs::BaseRig.count }.by(-1)
      end
    end
  let(:base_unit) { create(:base_unit) }
  let(:rig) { create(:base_rig, attachable: base_unit) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:rig_type) }
    it { should validate_presence_of(:capacity) }
    it { should validate_numericality_of(:capacity).is_greater_than_or_equal_to(0) }
  end

  describe '#apply_rig_to_attachable' do
    it 'applies rig effect to the attachable unit' do
      expect(base_unit).to receive(:update_consumables).at_least(:once)
      rig.apply_effects
    end
  end

  describe '#remove_from' do
    it 'removes rig effect from the attachable unit' do
      expect(base_unit).to receive(:update_consumables).at_least(:once)
      rig.remove_from
    end
  end

  describe 'polymorphic association' do
    it 'can belong to an attachable BaseUnit' do
      expect(rig.attachable).to eq(base_unit)
      expect(base_unit.persisted_rigs).to include(rig)
    end

    it 'can be unattached from a unit' do
      rig.remove_from
      expect(rig.attachable).to be_nil
    end
  end

  describe 'operational data' do
    it 'has an operational_data field with default values' do
      expected_data = {
        "consumables" => {
          "energy" => -50,
          "maintenance_effort" => 10
        }
      }
      expect(rig.operational_data).to eq(expected_data)
    end

    it 'can store and update operational data' do
      rig.operational_data = { "health" => 80, "power" => 20 }
      rig.save!
      rig.reload
      expect(rig.operational_data).to eq({ "health" => 80, "power" => 20 })
    end
  end

  describe '.load_from_json' do
    before do
      rig_lookup_service = instance_double(Lookup::RigLookupService)
      test_data = {
        'name' => 'Test Rig',
        'description' => 'A test rig',
        'unit_type' => 'test_rig',
        'consumables' => { 'energy' => -30 }
      }
      allow(Lookup::RigLookupService).to receive(:new).and_return(rig_lookup_service)
      allow(rig_lookup_service).to receive(:find_rig).with('test_rig').and_return(test_data)
    end

    it 'creates a new rig instance from JSON data' do
      rig = Rigs::BaseRig.load_from_json('test_rig')
      expect(rig).to be_a(Rigs::BaseRig)
      expect(rig.name).to eq('Test Rig')
      expect(rig.description).to eq('A test rig')
      expect(rig.rig_type).to eq('test_rig')
      expect(rig.operational_data).to include('consumables' => { 'energy' => -30 })
    end
  end

  describe '#process_tick' do
    it 'does not raise error when called' do
      expect { rig.process_tick }.not_to raise_error
    end
  end

  describe '#apply_output_effects and #revert_output_effects' do
    let(:output_data) do
      {
        "output_resources" => [
          { "id" => "water", "amount" => 10 },
          { "id" => "oxygen", "amount" => 5 }
        ]
      }
    end

    it 'applies and reverts output effects if attachable responds to update_outputs' do
      rig.operational_data = output_data
      allow(base_unit).to receive(:update_outputs)
      rig.send(:apply_output_effects)
      rig.send(:revert_output_effects, base_unit)
      expect(base_unit).to have_received(:update_outputs).with("water", 10)
      expect(base_unit).to have_received(:update_outputs).with("oxygen", 5)
      expect(base_unit).to have_received(:update_outputs).with("water", -10)
      expect(base_unit).to have_received(:update_outputs).with("oxygen", -5)
    end
  end

  describe '#apply_damage_effects and #revert_damage_effects' do
    let(:damage_data) do
      {
        "damage_risk" => {
          "corrosion" => 2,
          "impact" => 1
        }
      }
    end

    it 'applies and reverts damage effects if attachable responds to update_damage_risks' do
      rig.operational_data = damage_data
      allow(base_unit).to receive(:update_damage_risks)
      rig.send(:apply_damage_effects)
      rig.send(:revert_damage_effects, base_unit)
      expect(base_unit).to have_received(:update_damage_risks).with("corrosion", 2)
      expect(base_unit).to have_received(:update_damage_risks).with("impact", 1)
      expect(base_unit).to have_received(:update_damage_risks).with("corrosion", -2)
      expect(base_unit).to have_received(:update_damage_risks).with("impact", -1)
    end
  end
end
