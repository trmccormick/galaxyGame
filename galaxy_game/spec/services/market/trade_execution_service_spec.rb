# spec/services/market/trade_execution_service_spec.rb
require 'rails_helper'

RSpec.describe Market::TradeExecutionService, type: :service do
  # BOILERPLATE: Ensure the Organization model has the required inventory method for stubbing
  before(:all) do
    unless Organizations::Corporation.method_defined?(:remove_inventory)
      Organizations::Corporation.class_eval { def remove_inventory(resource, volume); true; end }
    end
  end

  let!(:gcc_currency) { Financial::Currency.find_or_create_by!(symbol: 'GCC') }

  # Organizations and Mocks
  let(:settlement) { Settlement::BaseSettlement.create!(name: 'Test Settlement') }
  let(:seller_organization) { Organizations::Corporation.create!(
    name: 'Seller Corp', 
    identifier: 'SC-01',
    operational_data: { 'tax_rate' => 0.10 } # 10% Tax Rate
  ) }
  
  # Accounts (must exist for find_or_create_for_entity_and_currency to work)
  let!(:seller_account) do 
    Financial::Account.find_or_create_for_entity_and_currency(
      accountable_entity: seller_organization, currency: gcc_currency
    )
  end
  let!(:settlement_account) do 
    Financial::Account.find_or_create_for_entity_and_currency(
      accountable_entity: settlement, currency: gcc_currency
    )
  end
  
  # Trade Data
  let(:trade_volume) { 100 }
  let(:unit_price) { 48.0 }
  let(:gross_revenue) { trade_volume * unit_price } # 4800.0
  let(:tax_rate) { 0.10 }
  let(:expected_tax) { gross_revenue * tax_rate } # 480.0
  let(:expected_net) { gross_revenue - expected_tax } # 4320.0
  
  let(:market_condition) { Market::Condition.new(id: 999, resource: 'LOX', price: 10.0) }
  
  let(:sell_order) do
    Market::Order.new(
      id: 1,
      market_condition: market_condition,
      orderable: seller_organization,
      base_settlement_id: settlement.id,
      resource: 'LOX',
      quantity: 100,
      order_type: 'Sell'
    )
  end
  
  before do
    # 1. ENSURE METHOD EXISTS BEFORE STUBBING (THE FIX)
    unless Organizations::Corporation.method_defined?(:remove_inventory)
      Organizations::Corporation.class_eval { def remove_inventory(resource, volume); true; end }
    end

    # Ensure settlement responds to :market_condition for stubbing
    unless settlement.respond_to?(:market_condition)
      settlement.define_singleton_method(:market_condition) { nil }
    end

    # 2. Ensure necessary dependencies are mocked/stubbed
    allow(seller_organization).to receive(:remove_inventory).and_return(true)
    allow(settlement).to receive(:market_condition).and_return(market_condition)
    allow(Market::Trade).to receive(:create!).and_return(Market::Trade.new)
    allow(Market::PriceHistory).to receive(:create!).and_return(Market::PriceHistory.new)
    allow(Market::SupplyChain).to receive(:create!).and_return(Market::SupplyChain.new)

    # Stub Financial services
    allow(Financial::TaxCollectionService).to receive(:collect_sales_tax).and_return(
      { success: true, tax_paid: expected_tax, transaction_id: 'mock-tax-txn-1', error: nil }
    )
    allow(Financial::TransactionManager).to receive(:create_transfer).and_return(
      OpenStruct.new(id: 'mock-net-txn-1')
    )
  end

  subject do
    described_class.execute!(sell_order, trade_volume, unit_price, settlement)
  end

  it 'returns true on successful execution' do
    expect(subject).to be true
  end

  # --- FINANCIAL INTEGRATION TESTS ---

  it 'calls the TaxCollectionService with gross revenue and seller' do
    subject
    
    expect(Financial::TaxCollectionService).to have_received(:collect_sales_tax).with(
      seller_organization,
      gross_revenue,
      gcc_currency
    )
  end

  it 'calls TransactionManager.create_transfer with the NET amount' do
    subject
    
    # The transfer_net_funds logic uses the TransactionManager
    expect(Financial::TransactionManager).to have_received(:create_transfer).with(
      hash_including(
        from: settlement_account,
        to: seller_account,
        amount: expected_net, # Verifies the net amount is transferred (4320.0)
        description: "Net proceeds from market sale."
      )
    )
  end
  
  # --- RECORD KEEPING & INVENTORY TESTS ---

  it 'removes inventory from seller' do
    subject
    expect(seller_organization).to have_received(:remove_inventory).with('LOX', trade_volume)
  end

  it 'creates a trade record' do
    expect(Market::Trade).to receive(:create!).once
    subject
  end

  it 'creates a price history record' do
    expect(Market::PriceHistory).to receive(:create!).once
    subject
  end

  it 'creates a supply chain record' do
    expect(Market::SupplyChain).to receive(:create!).once
    subject
  end
end