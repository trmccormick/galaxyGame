require 'rails_helper'

RSpec.describe Organizations::BaseOrganization, type: :model do
  let(:consortium) { create(:consortium, operational_data: {}, organization_type: :consortium) }
  let(:member) { create(:corporation) }

  before do
    ConsortiumMembership.create!(consortium: consortium, member: member, investment_amount: 1_000_000, ownership_percentage: 100.0, voting_power: 10000, membership_status: 'active', joined_at: Time.current)
    allow(consortium).to receive(:calculate_revenue).and_return(1_000_000)
    allow(consortium).to receive(:calculate_costs).and_return(100_000)
  end

  it 'distributes profits to members based on ownership' do
    expect {
      consortium.distribute_consortium_profits(consortium)
    }.to change { FinancialTransaction.count }.by(1)
    tx = FinancialTransaction.last
    expect(tx.amount).to eq(900_000)
    expect(tx.to_organization).to eq(member)
    expect(tx.from_organization).to eq(consortium)
    expect(tx.transaction_type).to eq('profit_distribution')
  end
end
