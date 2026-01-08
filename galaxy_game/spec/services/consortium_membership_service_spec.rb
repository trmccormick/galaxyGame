require 'rails_helper'

describe ConsortiumMembershipService, type: :service do
  let(:consortium) { create(:consortium, operational_data: { 'total_capital' => 2_000_000 }) }
  let(:corp) { create(:corporation) }
  let(:small_corp) { create(:corporation) }

  it 'allows a corporation to apply for membership with sufficient investment' do
    result = described_class.apply_for_membership(corp, consortium, 1_500_000)
    expect(result[:success]).to be true
    membership = ConsortiumMembership.find_by(consortium: consortium, member: corp)
    expect(membership).not_to be_nil
    expect(membership.investment_amount).to eq(1_500_000)
    expect(membership.ownership_percentage).to be > 0
    expect(consortium.reload.operational_data['total_capital']).to eq(3_500_000)
  end

  it 'rejects non-corporation applicants' do
    fake_org = double('Org', organization_type: 'government')
    result = described_class.apply_for_membership(fake_org, consortium, 2_000_000)
    expect(result[:success]).to be false
    expect(result[:reason]).to match(/Only corporations/)
  end

  it 'rejects applications with insufficient investment' do
    result = described_class.apply_for_membership(small_corp, consortium, 500_000)
    expect(result[:success]).to be false
    expect(result[:reason]).to match(/Insufficient investment/)
  end

  it 'dilutes existing members and assigns correct ownership' do
    member1 = create(:corporation)
    member2 = create(:corporation)
    create(:consortium_membership, consortium: consortium, member: member1, investment_amount: 1_000_000, ownership_percentage: 50.0, voting_power: 5000)
    create(:consortium_membership, consortium: consortium, member: member2, investment_amount: 1_000_000, ownership_percentage: 50.0, voting_power: 5000)
    result = described_class.apply_for_membership(corp, consortium, 1_000_000)
    expect(result[:success]).to be true
    consortium.reload
    total_ownership = consortium.member_relationships.sum(:ownership_percentage)
    expect(total_ownership).to be_within(0.01).of(100.0)
  end
end
