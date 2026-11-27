# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Astronomy::SimbadClient do
  describe '#lookup_object' do
    context 'when base client returns success with full identity/astrometry fields' do
      let(:simbad_json) do
        {
          'data' => [
            {
              'oid' => 'I/264/appendix1',
              'mainid' => 'HD 209458',
              'identifier' => 'HD 209458, HIP 107836, GSC 02648-01932',
              'alias' => 'HD 209458, HIP 107836, GSC 02648-01932',
              'classObj' => 'F',
              'ra' => '221.878833',
              'dec' => '18.52889',
              'pmRA' => '-10.64',
              'pmDE' => '-26.85',
              'mu' => '28.8',
              'muPA' => '137.5',
              'distPM' => nil,
              'GA' => 'Gaia DR2',
              'bibref' => 'SIMBAD/ADS/bibref1',
              'OTHER_COOSYS2' => 'ICRS',
              'Vmag' => '7.65',
              'BTmag' => nil,
              'Ty1mag' => nil,
              'Jmag' => '6.89',
              'Hmag' => '6.34',
              'Ksmag' => '6.12'
            }
          ]
        }.to_json
      end

      let(:base_result) do
        Astronomy::Result.new(
          success: true,
          status: 200,
          body: simbad_json,
          error_kind: nil,
          metadata: { headers: {} }
        )
      end

      let(:base_client) do
        instance_double(Astronomy::BaseTapClient).tap do |mock|
          allow(mock).to receive(:query).and_return(base_result)
        end
      end

      let(:client) { described_class.new(base_client) }

      it 'returns a composed result with identity fields' do
        returned = client.lookup_object('HD 209458')

        expect(returned).to be_success
        expect(returned.metadata[:primary_id]).to eq('HD 209458')
        expect(returned.metadata[:identifiers]).to eq(['HD 209458', 'HIP 107836', 'GSC 02648-01932'])
        expect(returned.metadata[:aliases]).to eq(['HD 209458', 'HIP 107836', 'GSC 02648-01932'])
        expect(returned.metadata[:object_class]).to eq('F')
        expect(returned.metadata[:coordinates]).to include(
          ra: 221.878833,
          dec: 18.52889,
          frame: 'ICRS',
          epoch: 2000.0
        )
        expect(returned.metadata[:astrometry]).to include(
          pm_ra: -10.64,
          pm_de: -26.85,
          mu: 28.8,
          mu_pa: 137.5
        )
        expect(returned.metadata[:match_count]).to eq(1)
      end

      it 'delegates to the base client with correct path and params' do
        client.lookup_object('HD 209458')

        expect(base_client).to have_received(:query).with(path: '/sync', params: hash_including(format: 'json'))
      end
    end

    context 'when HTTP 2xx returns zero matching rows' do
      let(:base_result) do
        Astronomy::Result.new(
          success: true,
          status: 200,
          body: { 'data' => [] }.to_json,
          error_kind: nil,
          metadata: { headers: {} }
        )
      end

      let(:base_client) do
        instance_double(Astronomy::BaseTapClient).tap do |mock|
          allow(mock).to receive(:query).and_return(base_result)
        end
      end

      let(:client) { described_class.new(base_client) }

      it 'returns success with empty/no-match, not unavailable' do
        returned = client.lookup_object('NONEXISTENT_OBJECT')

        expect(returned).to be_success
        expect(returned.error_kind).to be_nil
        expect(returned.metadata[:match_count]).to eq(0)
        expect(returned.metadata[:primary_id]).to be_nil
      end
    end

    context 'when base client returns success with nil body' do
      let(:base_result) do
        Astronomy::Result.new(
          success: true,
          status: 200,
          body: nil,
          error_kind: nil,
          metadata: { headers: {} }
        )
      end

      let(:base_client) do
        instance_double(Astronomy::BaseTapClient).tap do |mock|
          allow(mock).to receive(:query).and_return(base_result)
        end
      end

      let(:client) { described_class.new(base_client) }

      it 'treats nil body as empty/no-match, not an error' do
        returned = client.lookup_object('HD 209458')

        expect(returned).to be_success
        expect(returned.error_kind).to be_nil
        expect(returned.metadata[:match_count]).to eq(0)
      end
    end

    context 'when base client returns success with empty body' do
      let(:base_result) do
        Astronomy::Result.new(
          success: true,
          status: 200,
          body: '',
          error_kind: nil,
          metadata: { headers: {} }
        )
      end

      let(:base_client) do
        instance_double(Astronomy::BaseTapClient).tap do |mock|
          allow(mock).to receive(:query).and_return(base_result)
        end
      end

      let(:client) { described_class.new(base_client) }

      it 'treats empty body as empty/no-match, not an error' do
        returned = client.lookup_object('HD 209458')

        expect(returned).to be_success
        expect(returned.error_kind).to be_nil
        expect(returned.metadata[:match_count]).to eq(0)
      end
    end

    context 'when base client returns :timeout' do
      let(:base_result) do
        Astronomy::Result.new(
          success: false,
          status: nil,
          body: nil,
          error_kind: :timeout,
          metadata: { error_class: 'Timeout::Error', error_message: 'execution expired' }
        )
      end

      let(:base_client) do
        instance_double(Astronomy::BaseTapClient).tap do |mock|
          allow(mock).to receive(:query).and_return(base_result)
        end
      end

      let(:client) { described_class.new(base_client) }

      it 'propagates :timeout unchanged' do
        returned = client.lookup_object('HD 209458')

        expect(returned.error_kind).to eq(:timeout)
        expect(returned).not_to be_success
      end
    end

    context 'when base client returns :unavailable' do
      let(:base_result) do
        Astronomy::Result.new(
          success: false,
          status: 503,
          body: nil,
          error_kind: :unavailable,
          metadata: { error_class: 'SocketError', error_message: 'getaddrinfo: Name or service not known' }
        )
      end

      let(:base_client) do
        instance_double(Astronomy::BaseTapClient).tap do |mock|
          allow(mock).to receive(:query).and_return(base_result)
        end
      end

      let(:client) { described_class.new(base_client) }

      it 'propagates :unavailable unchanged' do
        returned = client.lookup_object('HD 209458')

        expect(returned.error_kind).to eq(:unavailable)
        expect(returned).not_to be_success
      end
    end

    context 'when base client returns :unsuccessful' do
      let(:base_result) do
        Astronomy::Result.new(
          success: false,
          status: 429,
          body: '{"error": "rate limit exceeded"}',
          error_kind: :unsuccessful,
          metadata: { headers: { 'retry-after' => '60' } }
        )
      end

      let(:base_client) do
        instance_double(Astronomy::BaseTapClient).tap do |mock|
          allow(mock).to receive(:query).and_return(base_result)
        end
      end

      let(:client) { described_class.new(base_client) }

      it 'propagates :unsuccessful unchanged' do
        returned = client.lookup_object('HD 209458')

        expect(returned.error_kind).to eq(:unsuccessful)
        expect(returned).not_to be_success
      end
    end

    context 'when object name contains single quotes' do
      let(:simbad_json) do
        {
          'data' => [
            {
              'oid' => 'I/264/appendix1',
              'mainid' => "O'Brien",
              'identifier' => "O'Brien, HIP 12345",
              'alias' => "O'Brien, HIP 12345",
              'classObj' => 'G',
              'ra' => '100.0',
              'dec' => '-50.0',
              'pmRA' => nil,
              'pmDE' => nil,
              'mu' => nil,
              'muPA' => nil,
              'distPM' => nil,
              'GA' => nil,
              'bibref' => nil,
              'OTHER_COOSYS2' => nil,
              'Vmag' => nil,
              'BTmag' => nil,
              'Ty1mag' => nil,
              'Jmag' => nil,
              'Hmag' => nil,
              'Ksmag' => nil
            }
          ]
        }.to_json
      end

      let(:base_result) do
        Astronomy::Result.new(
          success: true,
          status: 200,
          body: simbad_json,
          error_kind: nil,
          metadata: { headers: {} }
        )
      end

      let(:base_client) do
        instance_double(Astronomy::BaseTapClient).tap do |mock|
          allow(mock).to receive(:query).and_return(base_result)
        end
      end

      let(:client) { described_class.new(base_client) }

      it 'escapes single quotes by doubling in the ADQL query' do
        client.lookup_object("O'Brien")

        expect(base_client).to have_received(:query).with(
          path: '/sync',
          params: hash_including(query: /identifier = 'O''Brien'/)
        )
      end
    end

    context 'when aliases contain multiple entries' do
      let(:simbad_json) do
        {
          'data' => [
            {
              'oid' => 'I/264/appendix1',
              'mainid' => 'Sirius',
              'identifier' => 'Sirius, Alpha CMa, HD 48954, HIP 32349, HR 2491, GJ 244 A',
              'alias' => 'Sirius, Alpha CMa, HD 48954, HIP 32349, HR 2491, GJ 244 A',
              'classObj' => 'A',
              'ra' => '101.287543',
              'dec' => '-16.716116',
              'pmRA' => '-546.05',
              'pmDE' => '-1223.07',
              'mu' => nil,
              'muPA' => nil,
              'distPM' => nil,
              'GA' => 'Gaia DR2',
              'bibref' => nil,
              'OTHER_COOSYS2' => nil,
              'Vmag' => '-1.46',
              'BTmag' => nil,
              'Ty1mag' => nil,
              'Jmag' => '0.03',
              'Hmag' => '-0.01',
              'Ksmag' => '0.00'
            }
          ]
        }.to_json
      end

      let(:base_result) do
        Astronomy::Result.new(
          success: true,
          status: 200,
          body: simbad_json,
          error_kind: nil,
          metadata: { headers: {} }
        )
      end

      let(:base_client) do
        instance_double(Astronomy::BaseTapClient).tap do |mock|
          allow(mock).to receive(:query).and_return(base_result)
        end
      end

      let(:client) { described_class.new(base_client) }

      it 'preserves all aliases, not just the first' do
        returned = client.lookup_object('Sirius')

        expect(returned.metadata[:aliases].length).to eq(6)
        expect(returned.metadata[:aliases]).to include('Sirius', 'Alpha CMa', 'HD 48954', 'HIP 32349', 'HR 2491', 'GJ 244 A')
      end

      it 'preserves all identifiers, not just the first' do
        returned = client.lookup_object('Sirius')

        expect(returned.metadata[:identifiers].length).to eq(6)
        expect(returned.metadata[:identifiers]).to include('Sirius', 'Alpha CMa', 'HD 48954', 'HIP 32349', 'HR 2491', 'GJ 244 A')
      end
    end

    context 'when the TAP response body is invalid JSON' do
      let(:base_result) do
        Astronomy::Result.new(
          success: true,
          status: 200,
          body: 'not valid json {{{',
          error_kind: nil,
          metadata: { headers: {} }
        )
      end

      let(:base_client) do
        instance_double(Astronomy::BaseTapClient).tap do |mock|
          allow(mock).to receive(:query).and_return(base_result)
        end
      end

      let(:client) { described_class.new(base_client) }

      it 'treats unparseable body as empty/no-match' do
        returned = client.lookup_object('HD 209458')

        expect(returned).to be_success
        expect(returned.error_kind).to be_nil
        expect(returned.metadata[:match_count]).to eq(0)
      end
    end

    context 'when coordinates are nil in the response' do
      let(:simbad_json) do
        {
          'data' => [
            {
              'oid' => 'I/264/appendix1',
              'mainid' => 'Test Object',
              'identifier' => '',
              'alias' => '',
              'classObj' => nil,
              'ra' => nil,
              'dec' => nil,
              'pmRA' => nil,
              'pmDE' => nil,
              'mu' => nil,
              'muPA' => nil,
              'distPM' => nil,
              'GA' => nil,
              'bibref' => nil,
              'OTHER_COOSYS2' => nil,
              'Vmag' => nil,
              'BTmag' => nil,
              'Ty1mag' => nil,
              'Jmag' => nil,
              'Hmag' => nil,
              'Ksmag' => nil
            }
          ]
        }.to_json
      end

      let(:base_result) do
        Astronomy::Result.new(
          success: true,
          status: 200,
          body: simbad_json,
          error_kind: nil,
          metadata: { headers: {} }
        )
      end

      let(:base_client) do
        instance_double(Astronomy::BaseTapClient).tap do |mock|
          allow(mock).to receive(:query).and_return(base_result)
        end
      end

      let(:client) { described_class.new(base_client) }

      it 'returns nil coordinates and astrometry when unavailable' do
        returned = client.lookup_object('Test Object')

        expect(returned).to be_success
        expect(returned.metadata[:coordinates]).to be_nil
        expect(returned.metadata[:astrometry]).to be_nil
        expect(returned.metadata[:match_count]).to eq(1)
      end
    end
  end

  describe 'ADQL query construction' do
    let(:base_result) do
      Astronomy::Result.new(
        success: true,
        status: 200,
        body: { 'data' => [] }.to_json,
        error_kind: nil,
        metadata: { headers: {} }
      )
    end

    let(:base_client) do
      instance_double(Astronomy::BaseTapClient).tap do |mock|
        allow(mock).to receive(:query).and_return(base_result)
      end
    end

    it 'escapes single quotes by doubling' do
      client = described_class.new(base_client)
      client.lookup_object("O'Brien's Star")

      expect(base_client).to have_received(:query).with(
        path: '/sync',
        params: hash_including(query: /identifier = 'O''Brien''s Star'/)
      )
    end

    it 'does not raw-interpolate the input' do
      client = described_class.new(base_client)
      client.lookup_object("'; DROP TABLE objects; --")

      expect(base_client).to have_received(:query).with(
        path: '/sync',
        params: hash_including(query: /identifier = '''; DROP TABLE objects; --'/)
      )
    end
  end

  describe 'initialization' do
    it 'creates a BaseTapClient with SIMBAD_TAP_BASE_URL when no base_client is provided' do
      client = described_class.new

      expect(client.instance_variable_get(:@base_client)).to be_a(Astronomy::BaseTapClient)
      expect(client.instance_variable_get(:@base_client).base_url).to eq(
        Astronomy::SimbadClient::SIMBAD_TAP_BASE_URL
      )
    end

    it 'uses the provided base_client when given' do
      custom_client = instance_double(Astronomy::BaseTapClient)
      client = described_class.new(custom_client)

      expect(client.instance_variable_get(:@base_client)).to eq(custom_client)
    end
  end
end
