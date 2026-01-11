require 'rails_helper'

describe Organizations::BaseOrganization, type: :model do
  let(:consortium) { create(:consortium, operational_data: { 'status' => 'Active', 'total_capital' => 1_000_000 }) }
    let(:corp1) { create(:corporation, name: 'Alpha Corp') }
    let(:corp2) { create(:corporation, name: 'Beta Corp') }
  let!(:membership1) { create(:consortium_membership, consortium: consortium, member: corp1, ownership_percentage: 60.0, membership_terms: { 'seat_on_board' => true, 'preferential_rates' => 0.15 }, voting_power: 3) }
  let!(:membership2) { create(:consortium_membership, consortium: consortium, member: corp2, ownership_percentage: 40.0, membership_terms: { 'seat_on_board' => false, 'preferential_rates' => 0.10 }, voting_power: 2) }

  it 'renders a text-based dashboard for a member' do
    dashboard = consortium.consortium_dashboard_for(corp1)
    expect(dashboard).to include('WORMHOLE TRANSIT CONSORTIUM')
    expect(dashboard).to include('Alpha Corp')
    expect(dashboard).to include('Beta Corp')
    expect(dashboard).to include('Profit Share: 60.0%')
    expect(dashboard).to include('Board Seat: Yes')
    expect(dashboard).to include('Transit Fee Discount: 15%')
    expect(dashboard).to include('Voting Power: 3')
  end

  it 'renders a text-based dashboard for a non-member' do
      outsider = create(:corporation, name: 'Gamma Corp')
    dashboard = consortium.consortium_dashboard_for(outsider)
    expect(dashboard).to include('Not a member')
  end
end
