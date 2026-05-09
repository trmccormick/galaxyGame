require 'rails_helper'

RSpec.describe WormholeConsortiumFormationService, type: :service do
  let!(:consortium) { create(:consortium, identifier: 'WH-CONSORTIUM', operational_data: {}) }
  let!(:astrolift) { Organizations::BaseOrganization.find_by!(identifier: 'ASTROLIFT') }
  let!(:ldc) { Organizations::BaseOrganization.find_by!(identifier: 'LDC') }

  it 'creates memberships for founding members and updates consortium operational_data' do
    expect {
      WormholeConsortiumFormationService.form_consortium
    }.to change { ConsortiumMembership.count }.by_at_least(2)

    consortium.reload
    expect(consortium.operational_data['status']).to eq('active')
    expect(consortium.operational_data['founding_members']).to include('ASTROLIFT', 'LDC')
    expect(consortium.operational_data['total_capital']).to be >= 10_000_000
  end

  it 'updates member operational_data with consortium membership' do
    WormholeConsortiumFormationService.form_consortium
    astrolift.reload
    ldc.reload
    expect(astrolift.operational_data['consortium_memberships']).to include('WH-CONSORTIUM')
    expect(ldc.operational_data['consortium_memberships']).to include('WH-CONSORTIUM')
  end
end
