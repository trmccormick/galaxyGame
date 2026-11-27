# frozen_string_literal: true

module Astronomy
  # Lightweight result value object returned by BaseTapClient#query.
  # Gives callers a structured success/failure outcome instead of raw transport exceptions.
  #
  # Fields:
  #   success?   - true for HTTP 2xx, false otherwise
  #   status     - HTTP status code (Integer), or nil when no HTTP response was received
  #   body       - raw response body (String), or nil when absent/empty
  #   error_kind - nil on success; :timeout, :unavailable or :unsuccessful on failure
  #   metadata   - Hash of transport details (e.g. response headers, error class/message).
  #                This is NOT a provenance schema; keys are informal and may change.
  class Result
    attr_reader :status, :body, :error_kind, :metadata

    def initialize(success:, status: nil, body: nil, error_kind: nil, metadata: {})
      @success = success
      @status = status
      @body = body
      @error_kind = error_kind
      @metadata = metadata
    end

    def self.success(status: nil, body: nil, metadata: {})
      new(success: true, status: status, body: body, error_kind: nil, metadata: metadata)
    end

    def self.failure(error_kind:, status: nil, body: nil, metadata: {})
      new(success: false, status: status, body: body, error_kind: error_kind, metadata: metadata)
    end

    def success?
      @success
    end

    def failure?
      !@success
    end
  end
end
