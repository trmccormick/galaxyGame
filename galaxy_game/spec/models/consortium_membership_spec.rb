require 'rails_helper'

RSpec.describe ConsortiumMembership, type: :model do
  let(:consortium) { create(:consortium) }
  let(:corporation) { create(:corporation) }
  let(:non_corp) { create(:organization, organization_type: 'government') }

  it 'is valid with valid attributes' do
    membership = ConsortiumMembership.new(
      consortium: consortium,
      member: corporation,
      investment_amount: 1_000_000,
      ownership_percentage: 10.0,
      voting_power: 1000,
      membership_status: 'active',
      joined_at: Time.current,
      membership_terms: { founding_member: true }
    )
    expect(membership).to be_valid
  end

  it 'is invalid if member is not a corporation' do
    membership = ConsortiumMembership.new(
      consortium: consortium,
      member: non_corp,
      investment_amount: 1_000_000,
      ownership_percentage: 10.0,
      voting_power: 1000
    )
    expect(membership).not_to be_valid
    expect(membership.errors[:member]).to include('must be a corporation')
  end

  it 'is invalid with zero investment' do
    membership = ConsortiumMembership.new(
      consortium: consortium,
      member: corporation,
      investment_amount: 0,
      ownership_percentage: 10.0,
      voting_power: 1000
    )
    expect(membership).not_to be_valid
  end

  it 'is invalid with ownership_percentage > 100' do
    membership = ConsortiumMembership.new(
      consortium: consortium,
      member: corporation,
      investment_amount: 1_000_000,
      ownership_percentage: 150.0,
      voting_power: 1000
    )
    expect(membership).not_to be_valid
  end

  it 'scopes active memberships' do
    active = ConsortiumMembership.create!(
      consortium: consortium,
      member: corporation,
      investment_amount: 1_000_000,
      ownership_percentage: 10.0,
      voting_power: 1000,
      membership_status: 'active',
      joined_at: Time.current
    )
    inactive = ConsortiumMembership.create!(
      consortium: consortium,
      member: create(:corporation),
      investment_amount: 1_000_000,
      ownership_percentage: 5.0,
      voting_power: 500,
      membership_status: 'inactive',
      joined_at: Time.current
    )
    expect(ConsortiumMembership.active).to include(active)
    expect(ConsortiumMembership.active).not_to include(inactive)
  end
end
