require 'rails_helper'

describe AIManager::EmMissionCoordinatorService do
  let(:settlement) {
    double('Settlement', find_available: double('Infra', id: 'orbital_em_skimmer_mid', efficiency: 0.7, capacity: 80, operational?: true, positioned?: true))
  }
  it 'assigns missions and finds available skimmer' do
    expect(settlement).to receive(:find_available).with('orbital_em_skimmer_mid')
    described_class.assign_missions(settlement)
  end
end
