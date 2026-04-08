require 'rails_helper'


RSpec.describe Organizations::BaseOrganization, type: :model do
  let(:currency) { Financial::Currency.find_or_create_by(symbol: 'GCC') { |c| c.name = 'Galactic Crypto Currency'; c.is_system_currency = true; c.precision = 8 } }
  let(:consortium) { create(:consortium, operational_data: {}, organization_type: :consortium) }
  let(:member) { create(:corporation) }

  before do
    # Ensure consortium has an account with currency
    create(:account, accountable: consortium, currency: currency)
    ConsortiumMembership.create!(consortium: consortium, member: member, investment_amount: 1_000_000, ownership_percentage: 100.0, voting_power: 10000, membership_status: 'active', joined_at: Time.current)
    allow(consortium).to receive(:calculate_revenue).and_return(1_000_000)
    allow(consortium).to receive(:calculate_costs).and_return(100_000)
  end

  it 'distributes profits to members based on ownership' do
    expect {
      consortium.distribute_consortium_profits(consortium)
    }.to change { Financial::Transaction.count }.by(1)
    tx = Financial::Transaction.last
    expect(tx.amount).to eq(900_000)
    expect(tx.recipient).to eq(member)
    expect(tx.account.accountable).to eq(consortium)
    expect(tx.transaction_type).to eq('transfer')
    expect(tx.currency).to eq(currency)
  end
end
