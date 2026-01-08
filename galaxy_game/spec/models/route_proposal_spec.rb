require 'rails_helper'

RSpec.describe RouteProposal, type: :model do
  let(:consortium) { create(:consortium, operational_data: { 'governance' => { 'approval_threshold' => 0.66 } }) }
  let(:proposer) { create(:corporation) }
  let(:proposal) { described_class.create!(consortium: consortium, proposer: proposer, target_system: 'BARNARD-01', justification: 'Test', estimated_traffic: 10000, proposal_fee_paid: 100_000) }

  before do
    ConsortiumMembership.create!(consortium: consortium, member: proposer, investment_amount: 1_000_000, ownership_percentage: 100.0, voting_power: 10000, membership_status: 'active', joined_at: Time.current)
  end

  it 'calculates vote outcome based on threshold' do
    RouteProposalVote.create!(proposal: proposal, voter: proposer, vote: 'approve', voting_power: 10000)
    expect(proposal.calculate_vote_outcome).to be true
  end

  it 'fails if votes do not meet threshold' do
    RouteProposalVote.create!(proposal: proposal, voter: proposer, vote: 'reject', voting_power: 10000)
    expect(proposal.calculate_vote_outcome).to be false
  end
end
