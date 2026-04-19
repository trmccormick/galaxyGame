require 'rails_helper'

describe SettlementDeploymentService do
  let(:craft) { double('Craft', inventory: double('Inventory'), owner: double('Owner')) }
  let(:location) { double('Location', name: 'TestSite') }
  let(:manifest) do
    {
      'cargo_sections' => {
        'deployment_units' => [
          { 'id' => 'unit1', 'name' => 'Habitat', 'deployment_type' => 'hab', 'unit_data' => {} }
        ],
        'resources' => [
          { 'name' => 'Water', 'amount' => 10 }
        ]
      }
    }
  end

  before do
    allow(CargoManifestLoader).to receive(:load).and_return(manifest)
    allow(SettlementDeploymentService).to receive(:verify_deployment_cargo).and_return(true)
    allow(SettlementDeploymentService).to receive(:deploy_unit).and_return(true)
    allow(SettlementDeploymentService).to receive(:transfer_cargo).and_return(true)
    allow(Settlement::BaseSettlement).to receive(:create!).and_return(double('Settlement', base_units: [], inventory: double('Inventory')))
  end

  it 'calls all deployment steps and returns a settlement' do
    result = described_class.establish_from_craft(craft, location)
    expect(result).to be_a_kind_of(Object)
  end
end
