require 'rails_helper'

RSpec.describe WormholeConsortiumFormationService, type: :service do
  let!(:consortium) { create(:consortium, identifier: 'WH-CONSORTIUM', operational_data: {}) }
  let!(:astrolift) { create(:corporation, identifier: 'ASTROLIFT', operational_data: {}) }
  let!(:zenith) { create(:corporation, identifier: 'ZENITH', operational_data: {}) }
  let!(:vector) { create(:corporation, identifier: 'VECTOR', operational_data: {}) }

  it 'creates memberships for founding members and updates consortium operational_data' do
    expect {
      WormholeConsortiumFormationService.form_consortium
    }.to change { ConsortiumMembership.count }.by(3)

    consortium.reload
    expect(consortium.operational_data['status']).to eq('active')
    expect(consortium.operational_data['founding_members']).to include('ASTROLIFT', 'ZENITH', 'VECTOR')
    expect(consortium.operational_data['total_capital']).to eq(22_500_000)
  end

  it 'updates member operational_data with consortium membership' do
    WormholeConsortiumFormationService.form_consortium
    astrolift.reload
    expect(astrolift.operational_data['consortium_memberships']).to include('WH-CONSORTIUM')
  end
end
