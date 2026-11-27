# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Astronomy::BaseTapClient do
  let(:base_url) { 'https://example.com/tap' }
  let(:timeout) { 30 }
  let(:client) { described_class.new(base_url: base_url, timeout: timeout) }

  # Stubs only the transport boundary (Net::HTTP); the client itself runs for real.
  let(:http) do
    instance_double(Net::HTTP).tap do |h|
      allow(h).to receive(:open_timeout=)
      allow(h).to receive(:read_timeout=)
      allow(h).to receive(:use_ssl=)
    end
  end

  def http_response(code, body: nil, headers: {})
    instance_double(Net::HTTPResponse, code: code.to_s, body: body, to_hash: headers)
  end

  def stub_response(code, body: nil, headers: {})
    allow(Net::HTTP).to receive(:new).and_return(http)
    allow(http).to receive(:request).and_return(http_response(code, body: body, headers: headers))
  end

  def stub_error(error)
    allow(Net::HTTP).to receive(:new).and_return(http)
    allow(http).to receive(:request).and_raise(error)
  end

  describe '#query' do
    context 'with a 2xx response' do
      it 'returns a successful result with status and body' do
        stub_response(200, body: '{"data": "result"}', headers: { 'content-type' => ['application/json'] })

        result = client.query(path: '/sync', params: { query: 'ADQL' })

        expect(result).to be_success
        expect(result.status).to eq(200)
        expect(result.body).to eq('{"data": "result"}')
        expect(result.error_kind).to be_nil
        expect(result.metadata[:headers]).to eq('content-type' => ['application/json'])
      end

      it 'treats an empty body as nil' do
        stub_response(204, body: '')

        result = client.query(path: '/sync')

        expect(result).to be_success
        expect(result.status).to eq(204)
        expect(result.body).to be_nil
      end

      it 'treats a nil body as nil' do
        stub_response(200, body: nil)

        expect(client.query(path: '/sync').body).to be_nil
      end
    end

    context 'building the request' do
      it 'sends host, port, path and form-encoded params to Net::HTTP' do
        sent = nil
        allow(Net::HTTP).to receive(:new).with('example.com', 443).and_return(http)
        allow(http).to receive(:request) do |req|
          sent = req
          http_response(200, body: 'ok')
        end

        client.query(path: '/sync', params: { query: 'SELECT * FROM x', format: 'json' })

        expect(sent).to be_a(Net::HTTP::Get)
        expect(sent.path).to eq('/tap/sync?query=SELECT+*+FROM+x&format=json')
      end

      it 'preserves a non-default port from base_url' do
        expect(Net::HTTP).to receive(:new).with('example.com', 8443).and_return(http)
        allow(http).to receive(:request).and_return(http_response(200, body: 'ok'))

        described_class.new(base_url: 'https://example.com:8443/tap').query(path: '/sync')
      end

      it 'joins base path and path without doubled or missing slashes' do
        paths = []
        allow(Net::HTTP).to receive(:new).and_return(http)
        allow(http).to receive(:request) do |req|
          paths << req.path
          http_response(200, body: 'ok')
        end

        described_class.new(base_url: 'https://example.com/tap/').query(path: '/sync')
        described_class.new(base_url: 'https://example.com/tap').query(path: 'sync')
        described_class.new(base_url: 'https://example.com').query(path: '/sync')

        expect(paths).to eq(['/tap/sync', '/tap/sync', '/sync'])
      end

      it 'omits the query string when there are no params' do
        sent = nil
        allow(Net::HTTP).to receive(:new).and_return(http)
        allow(http).to receive(:request) do |req|
          sent = req
          http_response(200, body: 'ok')
        end

        client.query(path: '/sync')

        expect(sent.path).to eq('/tap/sync')
      end

      it 'enables SSL for https and disables it for http' do
        allow(Net::HTTP).to receive(:new).and_return(http)
        allow(http).to receive(:request).and_return(http_response(200, body: 'ok'))

        client.query(path: '/sync')
        expect(http).to have_received(:use_ssl=).with(true)

        described_class.new(base_url: 'http://example.com/tap').query(path: '/sync')
        expect(http).to have_received(:use_ssl=).with(false)
      end

      it 'applies the configured timeout to open and read' do
        stub_response(200, body: 'ok')

        described_class.new(base_url: base_url, timeout: 7).query(path: '/sync')

        expect(http).to have_received(:open_timeout=).with(7)
        expect(http).to have_received(:read_timeout=).with(7)
      end

      it 'raises ArgumentError when the path cannot form a valid URL' do
        expect { client.query(path: '/sync?x=1') }.to raise_error(ArgumentError, /invalid path/)
      end
    end

    context 'on timeout' do
      [
        Timeout::Error.new('Read timed out'),
        Net::OpenTimeout.new('open timed out'),
        Net::ReadTimeout.new('read timed out'),
        Errno::ETIMEDOUT.new('connect timed out')
      ].each do |error|
        it "returns :timeout for #{error.class}" do
          stub_error(error)

          result = client.query(path: '/sync')

          expect(result).not_to be_success
          expect(result.error_kind).to eq(:timeout)
          expect(result.status).to be_nil
          expect(result.metadata[:error_class]).to eq(error.class.name)
          expect(result.metadata[:error_message]).to be_a(String)
        end
      end
    end

    context 'on connection-level failure' do
      [
        Errno::ECONNREFUSED.new('refused'),
        Errno::ECONNRESET.new('reset'),
        Errno::EHOSTUNREACH.new('unreachable'),
        SocketError.new('getaddrinfo: Name or service not known'),
        OpenSSL::SSL::SSLError.new('certificate verify failed'),
        EOFError.new('end of file reached'),
        Net::HTTPBadResponse.new('wrong status line')
      ].each do |error|
        it "returns :unavailable for #{error.class}" do
          stub_error(error)

          result = client.query(path: '/sync')

          expect(result).not_to be_success
          expect(result.error_kind).to eq(:unavailable)
          expect(result.status).to be_nil
          expect(result.metadata[:error_class]).to eq(error.class.name)
        end
      end

      it 'does not swallow unexpected non-network errors' do
        stub_error(NoMethodError.new('programmer bug'))

        expect { client.query(path: '/sync') }.to raise_error(NoMethodError, 'programmer bug')
      end
    end

    context 'on HTTP 5xx response' do
      [500, 503].each do |code|
        it "returns :unavailable for #{code}, keeping status and body" do
          stub_response(code, body: 'server trouble')

          result = client.query(path: '/sync')

          expect(result).not_to be_success
          expect(result.error_kind).to eq(:unavailable)
          expect(result.status).to eq(code)
          expect(result.body).to eq('server trouble')
        end
      end
    end

    context 'on HTTP 3xx response' do
      [301, 302].each do |code|
        it "returns :unsuccessful for #{code} without following the redirect" do
          stub_response(code, body: 'moved', headers: { 'location' => ['https://example.com/other'] })

          result = client.query(path: '/sync')

          expect(result).not_to be_success
          expect(result.error_kind).to eq(:unsuccessful)
          expect(result.status).to eq(code)
          expect(result.metadata[:headers]['location']).to eq(['https://example.com/other'])
          expect(http).to have_received(:request).once
        end
      end
    end

    context 'on HTTP 4xx response' do
      { 400 => 'Bad Request', 404 => 'Not Found', 429 => 'Too Many Requests' }.each do |code, text|
        it "returns :unsuccessful for #{code}, keeping status and body" do
          stub_response(code, body: text)

          result = client.query(path: '/sync')

          expect(result).not_to be_success
          expect(result.error_kind).to eq(:unsuccessful)
          expect(result.status).to eq(code)
          expect(result.body).to eq(text)
        end
      end
    end

    context 'on an unexpected status code' do
      it 'returns :unsuccessful, not :unavailable, for a status outside 2xx-5xx' do
        stub_response(600, body: 'odd')

        result = client.query(path: '/sync')

        expect(result.error_kind).to eq(:unsuccessful)
        expect(result.status).to eq(600)
      end
    end
  end

  describe 'initialization' do
    it 'raises ArgumentError for nil base_url' do
      expect { described_class.new(base_url: nil) }.to raise_error(ArgumentError, 'base_url is required')
    end

    it 'raises ArgumentError for empty or blank base_url' do
      expect { described_class.new(base_url: '') }.to raise_error(ArgumentError, 'base_url is required')
      expect { described_class.new(base_url: '   ') }.to raise_error(ArgumentError, 'base_url is required')
    end

    it 'raises ArgumentError for a non-http(s) or hostless base_url' do
      expect { described_class.new(base_url: 'ftp://example.com/tap') }.to raise_error(ArgumentError, /http\(s\)/)
      expect { described_class.new(base_url: 'https:///tap') }.to raise_error(ArgumentError, /http\(s\)/)
      expect { described_class.new(base_url: 'not a url') }.to raise_error(ArgumentError, /base_url/)
    end

    it 'uses the default timeout when not specified' do
      expect(described_class.new(base_url: base_url).timeout).to eq(30)
      expect(described_class::DEFAULT_TIMEOUT).to eq(30)
    end

    it 'accepts a custom timeout' do
      expect(described_class.new(base_url: base_url, timeout: 60).timeout).to eq(60)
    end
  end
end

RSpec.describe Astronomy::Result do
  it 'reports success? and failure? for a success result' do
    result = described_class.success(status: 200, body: 'x')

    expect(result).to be_success
    expect(result).not_to be_failure
    expect(result.error_kind).to be_nil
    expect(result.metadata).to eq({})
  end

  it 'reports success? and failure? for a failure result' do
    result = described_class.failure(error_kind: :timeout)

    expect(result).not_to be_success
    expect(result).to be_failure
    expect(result.status).to be_nil
    expect(result.body).to be_nil
  end
end
