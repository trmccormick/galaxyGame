# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Astronomy::NasaExoplanetArchiveClient do
  let(:base_url) { 'https://exoplanetarchive.ipac.caltech.edu/TAP' }
  let(:base_client) { instance_double(Astronomy::BaseTapClient) }
  let(:client) { described_class.new(base_client) }

  def http_response(code, body: nil, headers: {})
    instance_double(Net::HTTPResponse, code: code.to_s, body: body, to_hash: headers)
  end

  # Build a base-client result from an HTTP-like response.
  def base_result(status:, body: nil, error_kind: nil, metadata: {})
    Astronomy::Result.new(
      success: (200..299).cover?(status),
      status: status,
      body: body,
      error_kind: error_kind,
      metadata: metadata
    )
  end

  describe '#initialize' do
    it 'creates a base client with the default NEA TAP URL when none is provided' do
      allow(Astronomy::BaseTapClient).to receive(:new)
        .with(base_url: Astronomy::NasaExoplanetArchiveClient::NEA_TAP_BASE_URL)
        .and_return(instance_double(Astronomy::BaseTapClient))

      described_class.new
    end

    it 'uses the provided base client when given one' do
      allow(Astronomy::BaseTapClient).to receive(:new)
      described_class.new(base_client)
      expect(Astronomy::BaseTapClient).not_to have_received(:new)
    end
  end

  describe '#lookup_planets' do
    context 'with a successful response containing rows' do
      let(:json_body) do
        {
          'data' => [
            {
              'pl_plname' => 'Kepler-22b',
              'pl_hostname' => 'Kepler-22',
              'ra' => '283.5',
              'dec' => '44.9',
              'pl_bmasse' => '23.6',
              'pl_radem' => nil,
              'pl_rad' => '2.371',
              'pl_orbper' => '289.85',
              'pl_orbsmax' => '1.044',
              'pl_orbeccen' => '0.0',
              'pl_orbincl' => '89.631',
              'pl_masse' => nil,
              'pl_massr' => nil,
              'st_teff' => '5518.0',
              'st_logg' => '4.42',
              'st_met' => '0.22',
              'st_rad' => '1.136',
              'st_mass' => '0.97',
              'ra_errm' => '0.3',
              'dec_errm' => '0.3'
            }
          ]
        }.to_json
      end

      before do
        allow(base_client).to receive(:query)
          .and_return(base_result(status: 200, body: json_body))
      end

      it 'returns a successful result' do
        result = client.lookup_planets('Kepler-22')

        expect(result).to be_success
        expect(result.status).to eq(200)
        expect(result.error_kind).to be_nil
      end

      it 'sends the correct ADQL query to the base client' do
        client.lookup_planets('Kepler-22')

        expect(base_client).to have_received(:query).with(
          path: '/sync',
          params: {
            query: a_string_matching(/FROM ps/),
            format: 'json'
          }
        )
      end

      it 'escapes single quotes in the hostname' do
        client.lookup_planets("O'Brien")

        expect(base_client).to have_received(:query).with(
          hash_including(params: hash_including(query: a_string_matching("O''Brien")))
        )
      end

      it 'composes planet parameters into metadata' do
        result = client.lookup_planets('Kepler-22')

        expect(result.metadata[:planets]).to be_an(Array)
        expect(result.metadata[:planets].length).to eq(1)

        planet = result.metadata[:planets].first
        expect(planet[:name]).to eq('Kepler-22b')
        expect(planet[:hostname]).to eq('Kepler-22')
        expect(planet[:ra]).to eq(283.5)
        expect(planet[:dec]).to eq(44.9)
        expect(planet[:radius]).to eq(2.371)
        expect(planet[:orbital_period]).to eq(289.85)
        expect(planet[:eccentricity]).to eq(0.0)
        expect(planet[:inclination]).to eq(89.631)
      end

      it 'preserves nil values as nil in planet params' do
        result = client.lookup_planets('Kepler-22')

        planet = result.metadata[:planets].first
        expect(planet[:radius_error]).to be_nil
        expect(planet[:mass_earth]).to be_nil
        expect(planet[:mass_ratio]).to be_nil
      end

      it 'composes host stellar parameters into metadata' do
        result = client.lookup_planets('Kepler-22')

        expect(result.metadata[:host_parameters]).to be_a(Hash)
        expect(result.metadata[:host_parameters][:teff]).to eq(5518.0)
        expect(result.metadata[:host_parameters][:logg]).to eq(4.42)
        expect(result.metadata[:host_parameters][:metallicity]).to eq(0.22)
        expect(result.metadata[:host_parameters][:radius]).to eq(1.136)
        expect(result.metadata[:host_parameters][:mass]).to eq(0.97)
      end

      it 'records the match count' do
        result = client.lookup_planets('Kepler-22')

        expect(result.metadata[:match_count]).to eq(1)
      end

      it 'preserves base transport fields' do
        result = client.lookup_planets('Kepler-22')

        expect(result.status).to eq(200)
        expect(result.body).to eq(json_body)
      end
    end

    context 'with multiple matching planets' do
      let(:json_body) do
        {
          'data' => [
            {
              'pl_plname' => 'Kepler-22b',
              'pl_hostname' => 'Kepler-22',
              'ra' => '283.5',
              'dec' => '44.9',
              'pl_bmasse' => nil,
              'pl_radem' => nil,
              'pl_rad' => '2.371',
              'pl_orbper' => '289.85',
              'pl_orbsmax' => '1.044',
              'pl_orbeccen' => '0.0',
              'pl_orbincl' => '89.631',
              'pl_masse' => nil,
              'pl_massr' => nil,
              'st_teff' => '5518.0',
              'st_logg' => '4.42',
              'st_met' => '0.22',
              'st_rad' => '1.136',
              'st_mass' => '0.97',
              'ra_errm' => '0.3',
              'dec_errm' => '0.3'
            },
            {
              'pl_plname' => 'Kepler-22c',
              'pl_hostname' => 'Kepler-22',
              'ra' => '283.5',
              'dec' => '44.9',
              'pl_bmasse' => nil,
              'pl_radem' => nil,
              'pl_rad' => '1.5',
              'pl_orbper' => '400.0',
              'pl_orbsmax' => '1.2',
              'pl_orbeccen' => '0.05',
              'pl_orbincl' => '89.5',
              'pl_masse' => nil,
              'pl_massr' => nil,
              'st_teff' => '5518.0',
              'st_logg' => '4.42',
              'st_met' => '0.22',
              'st_rad' => '1.136',
              'st_mass' => '0.97',
              'ra_errm' => '0.3',
              'dec_errm' => '0.3'
            }
          ]
        }.to_json
      end

      before do
        allow(base_client).to receive(:query)
          .and_return(base_result(status: 200, body: json_body))
      end

      it 'returns all matching planets' do
        result = client.lookup_planets('Kepler-22')

        expect(result).to be_success
        expect(result.metadata[:planets].length).to eq(2)
        expect(result.metadata[:match_count]).to eq(2)
      end
    end

    context 'with an empty/no-match result (HTTP 2xx, zero rows)' do
      let(:json_body) { { 'data' => [] }.to_json }

      before do
        allow(base_client).to receive(:query)
          .and_return(base_result(status: 200, body: json_body))
      end

      it 'returns success, not unavailable' do
        result = client.lookup_planets('NonExistentStar')

        expect(result).to be_success
        expect(result.error_kind).to be_nil
      end

      it 'returns empty planets and match_count 0' do
        result = client.lookup_planets('NonExistentStar')

        expect(result.metadata[:planets]).to eq([])
        expect(result.metadata[:host_parameters]).to be_nil
        expect(result.metadata[:match_count]).to eq(0)
      end

      it 'does not claim the host has no planets' do
        result = client.lookup_planets('NonExistentStar')

        # Empty is unknown/no-match, not proof of absence.
        expect(result).to be_success
        expect(result.error_kind).not_to eq(:unavailable)
      end
    end

    context 'with an empty body' do
      before do
        allow(base_client).to receive(:query)
          .and_return(base_result(status: 200, body: nil))
      end

      it 'returns success with empty/no-match' do
        result = client.lookup_planets('Kepler-22')

        expect(result).to be_success
        expect(result.metadata[:planets]).to eq([])
        expect(result.metadata[:match_count]).to eq(0)
      end
    end

    context 'with an unparseable JSON body' do
      before do
        allow(base_client).to receive(:query)
          .and_return(base_result(status: 200, body: 'not json at all'))
      end

      it 'returns success with empty/no-match' do
        result = client.lookup_planets('Kepler-22')

        expect(result).to be_success
        expect(result.metadata[:planets]).to eq([])
        expect(result.metadata[:match_count]).to eq(0)
      end
    end

    context 'on transport timeout' do
      before do
        allow(base_client).to receive(:query)
          .and_return(base_result(status: nil, body: nil, error_kind: :timeout))
      end

      it 'returns the timeout result unchanged' do
        result = client.lookup_planets('Kepler-22')

        expect(result).not_to be_success
        expect(result.error_kind).to eq(:timeout)
        expect(result.metadata[:planets]).to be_nil
      end
    end

    context 'on transport unavailable (connection failure)' do
      before do
        allow(base_client).to receive(:query)
          .and_return(base_result(status: nil, body: nil, error_kind: :unavailable))
      end

      it 'returns the unavailable result unchanged' do
        result = client.lookup_planets('Kepler-22')

        expect(result).not_to be_success
        expect(result.error_kind).to eq(:unavailable)
      end
    end

    context 'on HTTP 5xx response' do
      before do
        allow(base_client).to receive(:query)
          .and_return(base_result(status: 503, body: 'server trouble', error_kind: :unavailable))
      end

      it 'returns the unavailable result unchanged' do
        result = client.lookup_planets('Kepler-22')

        expect(result).not_to be_success
        expect(result.error_kind).to eq(:unavailable)
        expect(result.status).to eq(503)
      end
    end

    context 'on HTTP 4xx response' do
      before do
        allow(base_client).to receive(:query)
          .and_return(base_result(status: 429, body: 'rate limited', error_kind: :unsuccessful))
      end

      it 'returns the unsuccessful result unchanged' do
        result = client.lookup_planets('Kepler-22')

        expect(result).not_to be_success
        expect(result.error_kind).to eq(:unsuccessful)
        expect(result.status).to eq(429)
      end
    end

    context 'with a nil hostname' do
      before do
        allow(base_client).to receive(:query)
          .and_return(base_result(status: 200, body: { 'data' => [] }.to_json))
      end

      it 'does not raise and returns empty/no-match' do
        expect { client.lookup_planets(nil) }.not_to raise_error

        result = client.lookup_planets(nil)
        expect(result).to be_success
        expect(result.metadata[:planets]).to eq([])
      end
    end

    context 'with an empty string hostname' do
      before do
        allow(base_client).to receive(:query)
          .and_return(base_result(status: 200, body: { 'data' => [] }.to_json))
      end

      it 'does not raise and returns empty/no-match' do
        expect { client.lookup_planets('') }.not_to raise_error

        result = client.lookup_planets('')
        expect(result).to be_success
        expect(result.metadata[:planets]).to eq([])
      end
    end
  end
end
