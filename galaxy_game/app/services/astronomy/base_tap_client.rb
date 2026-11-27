# frozen_string_literal: true

require 'net/http'
require 'openssl'
require 'timeout'
require 'uri'

module Astronomy
  # Shared TAP (Table Access Protocol) HTTP base client.
  #
  # Performs parameterized GET requests against a TAP endpoint and returns a
  # structured Astronomy::Result. Provider-specific ADQL/query construction,
  # caching, mirror policy and provenance are deliberately NOT handled here.
  #
  # Error classification (error_kind on the result):
  #   :timeout      - open/read timeout (Timeout::Error and subclasses, Errno::ETIMEDOUT)
  #   :unavailable  - connection refused/reset, DNS, TLS, socket and protocol errors, HTTP 5xx
  #   :unsuccessful - every other non-2xx response, including 3xx and 4xx (e.g. 429);
  #                   the HTTP status and body are preserved on the result
  #
  # Redirects: Net::HTTP does NOT follow redirects, and this client adds no redirect
  # policy. A 3xx response is returned as :unsuccessful with its status preserved.
  #
  # Raising vs returning: transport failures never raise; they return a failed Result.
  # Invalid programmer arguments (bad base_url, bad path) raise ArgumentError.
  # Unexpected non-network exceptions are intentionally NOT swallowed.
  class BaseTapClient
    DEFAULT_TIMEOUT = 30 # seconds, applied to both open and read timeouts

    # Network/protocol failures that mean "the service could not be reached or
    # did not answer sensibly". Timeouts are handled separately.
    UNAVAILABLE_ERRORS = [
      SocketError,
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::EHOSTUNREACH,
      Errno::ENETUNREACH,
      Errno::EPIPE,
      EOFError,
      IOError,
      OpenSSL::SSL::SSLError,
      Net::ProtocolError,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError
    ].freeze

    attr_reader :base_url, :timeout

    def initialize(base_url:, timeout: nil)
      if base_url.nil? || base_url.to_s.strip.empty?
        raise ArgumentError, 'base_url is required'
      end

      @base_url = base_url.to_s.strip
      @base_uri = parse_base_url(@base_url)
      @timeout = timeout || DEFAULT_TIMEOUT
    end

    # Execute a parameterized TAP GET request.
    #
    # @param path [String] endpoint path appended to the base URL (e.g. '/sync')
    # @param params [Hash] query parameters, form-encoded into the URL
    # @return [Astronomy::Result]
    # @raise [ArgumentError] if the path cannot form a valid URL
    def query(path:, params: {})
      uri = build_uri(path, params || {})
      perform_get(uri)
    end

    private

    def parse_base_url(url)
      uri = URI.parse(url)
      unless uri.is_a?(URI::HTTP) && !uri.host.to_s.empty?
        raise ArgumentError, 'base_url must be an http(s) URL with a host'
      end

      uri
    rescue URI::InvalidURIError
      raise ArgumentError, 'base_url must be a valid http(s) URL'
    end

    # Starts from the parsed base URI so scheme, host and port are preserved.
    def build_uri(path, params)
      uri = @base_uri.dup
      uri.path = join_paths(@base_uri.path, path.to_s)
      uri.query = params.empty? ? nil : URI.encode_www_form(params)
      uri
    rescue URI::InvalidComponentError => e
      raise ArgumentError, "invalid path: #{e.message}"
    end

    def join_paths(base_path, path)
      segments = [base_path, path].map { |s| s.gsub(%r{\A/+|/+\z}, '') }.reject(&:empty?)
      "/#{segments.join('/')}"
    end

    def perform_get(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http.open_timeout = timeout
      http.read_timeout = timeout

      classify_response(http.request(Net::HTTP::Get.new(uri.request_uri)))
    rescue Timeout::Error, Errno::ETIMEDOUT => e
      failure_from_exception(:timeout, e)
    rescue *UNAVAILABLE_ERRORS => e
      failure_from_exception(:unavailable, e)
    end

    def classify_response(response)
      status = response.code.to_i
      body = normalize_body(response.body)
      metadata = { headers: response.to_hash }

      if (200..299).cover?(status)
        Result.success(status: status, body: body, metadata: metadata)
      elsif (500..599).cover?(status)
        Result.failure(error_kind: :unavailable, status: status, body: body, metadata: metadata)
      else
        Result.failure(error_kind: :unsuccessful, status: status, body: body, metadata: metadata)
      end
    end

    def normalize_body(body)
      body.nil? || body.empty? ? nil : body
    end

    def failure_from_exception(kind, error)
      Result.failure(
        error_kind: kind,
        metadata: { error_class: error.class.name, error_message: error.message }
      )
    end
  end
end
