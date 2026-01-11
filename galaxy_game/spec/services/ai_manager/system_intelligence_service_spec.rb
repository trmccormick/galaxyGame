require 'rails_helper'
require_relative '../../../app/services/ai_manager'


RSpec.describe AIManager::SystemIntelligenceService do
  let(:celestial_body) { create(:celestial_body) }
  let(:service) { described_class.new(celestial_body) }

  describe '#system_status' do
    context 'with operational structures' do
      let(:settlement) { create(:base_settlement) }
      let!(:operational_structure) { create(:base_structure, :operational) }
      let!(:non_operational_structure) { create(:base_structure, :non_operational) }

      before do
        # Associate the settlement with the celestial body
        celestial_location = create(:celestial_location, locationable: settlement, celestial_body: celestial_body)
        settlement.update(location: celestial_location)
        # Update structures to belong to the settlement
        operational_structure.update(settlement: settlement)
        non_operational_structure.update(settlement: settlement)
      end

      it 'returns correct operational ratio and status' do
        status = service.system_status

        expect(status[:operational_structures].count).to eq(1)
        expect(status[:operational_ratio]).to eq(0.5)
        expect(status[:status]).to eq(:warning)
      end
    end

    context 'with all operational structures' do
      let(:settlement) { create(:base_settlement) }
      let!(:structure1) { create(:base_structure, :operational) }
      let!(:structure2) { create(:base_structure, :operational) }

      before do
        # Associate the settlement with the celestial body
        celestial_location = create(:celestial_location, locationable: settlement, celestial_body: celestial_body)
        settlement.update(location: celestial_location)
        # Update structures to belong to the settlement
        structure1.update(settlement: settlement)
        structure2.update(settlement: settlement)
      end

      it 'returns healthy status' do
        status = service.system_status

        expect(status[:operational_ratio]).to eq(1.0)
        expect(status[:status]).to eq(:healthy)
      end
    end

    context 'with mostly non-operational structures' do
      let!(:structure1) { create(:base_structure, :non_operational, location: create(:celestial_location, celestial_body: celestial_body)) }
      let!(:structure2) { create(:base_structure, :non_operational, location: create(:celestial_location, celestial_body: celestial_body)) }

      it 'returns critical status' do
        status = service.system_status

        expect(status[:operational_ratio]).to eq(0.0)
        expect(status[:status]).to eq(:critical)
      end
    end
  end

  describe '#narrative_status' do
    context 'critical status' do
      before do
        allow(service).to receive(:system_status).and_return({ operational_ratio: 0.3, status: :critical })
      end

      it 'returns critical narrative' do
        expect(service.narrative_status).to include('critical condition')
      end
    end

    context 'warning status' do
      before do
        allow(service).to receive(:system_status).and_return({ operational_ratio: 0.7, status: :warning })
      end

      it 'returns warning narrative' do
        expect(service.narrative_status).to include('warning signs')
      end
    end

    context 'healthy status' do
      before do
        allow(service).to receive(:system_status).and_return({ operational_ratio: 0.9, status: :healthy })
      end

      it 'returns healthy narrative' do
        expect(service.narrative_status).to include('healthy')
      end
    end
  end

  describe '#licensing_runway' do
    let(:ssc) { create(:organization, identifier: "#{celestial_body.name.parameterize.upcase}_DEV_CORP") }
    let(:usd_currency) { Financial::Currency.find_by(symbol: 'USD') || create(:currency, :usd) }

    before do
      allow(service).to receive(:find_system_specific_corp).and_return(ssc)
      allow(service).to receive(:calculate_average_daily_transit_fee).and_return(1000.0)
    end

    context 'with USD balance' do
      let!(:usd_account) { create(:financial_account, accountable: ssc, currency: usd_currency, balance: 5000.0) }

      it 'calculates runway correctly' do
        expect(service.licensing_runway).to eq(5.0)
      end
    end

    context 'with zero balance' do
      let!(:usd_account) { create(:financial_account, accountable: ssc, currency: usd_currency, balance: 0.0) }

      it 'returns zero runway' do
        expect(service.licensing_runway).to eq(0.0)
      end
    end

    context 'no SSC found' do
      before do
        allow(service).to receive(:find_system_specific_corp).and_return(nil)
      end

      it 'returns nil' do
        expect(service.licensing_runway).to be_nil
      end
    end
  end

  describe '#sustainability_delta' do
    before do
      allow(service).to receive(:calculate_total_production).and_return(1000)
      allow(service).to receive(:calculate_total_consumption).and_return(800)
    end

    it 'calculates positive delta' do
      expect(service.sustainability_delta).to eq(200)
    end
  end

  describe '#logistics_efficiency' do
    let(:settlement1) { create(:base_settlement) }
    let(:settlement2) { create(:base_settlement) }

    before do
      # Associate settlements with the celestial body
      celestial_location1 = create(:celestial_location, locationable: settlement1, celestial_body: celestial_body)
      celestial_location2 = create(:celestial_location, locationable: settlement2, celestial_body: celestial_body)
      settlement1.update(location: celestial_location1)
      settlement2.update(location: celestial_location2)
    end

    context 'with contracts' do
      let!(:fulfilled_contract) { create(:logistics_contract, status: :delivered, from_settlement: settlement1, to_settlement: settlement2) }
      let!(:unfulfilled_contract) { create(:logistics_contract, status: :pending, from_settlement: settlement1, to_settlement: settlement2) }

      it 'calculates efficiency' do
        expect(service.logistics_efficiency).to eq(0.5)
      end
    end

    context 'no contracts' do
      it 'returns 0.0' do
        expect(service.logistics_efficiency).to eq(0.0)
      end
    end
  end

  describe '#economic_health_score' do
    let(:ssc) { create(:organization) }
    let(:gcc_currency) { Financial::Currency.find_by(symbol: 'GCC') || create(:currency, :gcc) }
    let(:usd_currency) { Financial::Currency.find_by(symbol: 'USD') || create(:currency, :usd) }

    before do
      allow(service).to receive(:find_system_specific_corp).and_return(ssc)
    end

    context 'with balances' do
      before do
        # Update existing accounts with test balances
        gcc_account = Financial::Account.find_by(accountable: ssc, currency: gcc_currency)
        usd_account = Financial::Account.find_by(accountable: ssc, currency: usd_currency)
        
        # Create GCC account if it doesn't exist
        unless gcc_account
          gcc_account = Financial::Account.create!(
            accountable: ssc,
            currency: gcc_currency,
            balance: 0.0
          )
        end
        
        # Create USD account if it doesn't exist
        unless usd_account
          usd_account = Financial::Account.create!(
            accountable: ssc,
            currency: usd_currency,
            balance: 0.0
          )
        end
        
        gcc_account.update(balance: 50000.0)
        usd_account.update(balance: 100000.0)
      end

      it 'calculates score' do
        expect(service.economic_health_score).to eq(75) # 25 + 50
      end
    end

    context 'no SSC' do
      before do
        allow(service).to receive(:find_system_specific_corp).and_return(nil)
      end

      it 'returns 0' do
        expect(service.economic_health_score).to eq(0)
      end
    end
  end
end