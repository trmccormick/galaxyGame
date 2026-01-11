require 'rails_helper'

RSpec.describe RouteProposalVote, type: :model do
  let(:proposal) { create(:route_proposal) }
  let(:voter) { create(:corporation) }

  it 'is valid with valid attributes' do
    vote = described_class.new(proposal: proposal, voter: voter, vote: 'approve', voting_power: 1000)
    expect(vote).to be_valid
  end

  it 'is invalid with an invalid vote value' do
    vote = described_class.new(proposal: proposal, voter: voter, vote: 'maybe', voting_power: 1000)
    expect(vote).not_to be_valid
    expect(vote.errors[:vote]).to include('is not included in the list')
  end
end
