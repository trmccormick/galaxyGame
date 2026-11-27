# frozen_string_literal: true

module Astronomy
  # SIMBAD provider client for targeted object identity and astrometry lookups.
  #
  # Delegates HTTP transport to {Astronomy::BaseTapClient} and composes
  # {Astronomy::Result} with informal identity/astrometry fields extracted
  # from the raw TAP response body. No provenance schema is invented here;
  # callers may interpret the raw body independently.
  #
  # Error classification (error_kind on the result) comes entirely from the
  # base client: :timeout, :unavailable, or :unsuccessful. An HTTP 2xx
  # response with zero matching rows is treated as successful transport with
  # an empty/no-match result — it does not set error_kind to unavailable.
  class SimbadClient
    # Public SIMBAD TAP sync base URL (free, no authentication required).
    SIMBAD_TAP_BASE_URL = 'https://simbad.cds.unistra.fr/simbad/sim-tap'.freeze

    # @param base_client [Astronomy::BaseTapClient, nil] optional dependency-injected client;
    #   creates a new one with {SIMBAD_TAP_BASE_URL} when omitted.
    def initialize(base_client = nil)
      @base_client = base_client || BaseTapClient.new(base_url: SIMBAD_TAP_BASE_URL)
    end

    # Perform a targeted SIMBAD lookup by object name or catalog identifier.
    #
    # @param name_or_id [String] the SIMBAD object name or catalog identifier to look up.
    #   Single quotes in the input are escaped by doubling (SQL standard).
    # @return [Astronomy::Result] composed result with base transport fields plus
    #   informal identity/astrometry fields when the response is successful and parseable.
    #   Empty results (zero rows) return success + empty/no-match, not an error_kind.
    def lookup_object(name_or_id)
      query = build_lookup_query(name_or_id)
      result = @base_client.query(path: '/sync', params: { query: query, format: 'json' })
      parse_response(result)
    end

    private

    # Build an ADQL TAP query for a targeted name/identifier lookup.
    # Single quotes in the input are escaped by doubling (SQL standard).
    #
    # @param name_or_id [String] the object name or identifier.
    # @return [String] the ADQL query string.
    def build_lookup_query(name_or_id)
      escaped = name_or_id.to_s.gsub("'", "''")
      <<~ADQL.strip
        SELECT TOP 1
          o.id AS oid,
          o.mainid,
          o.alias,
          o.classObj,
          o.ra,
          o.dec,
          o.pmRA,
          o.pmDE,
          o.mu,
          o.muPA,
          o.distPM,
          o.GA,
          o.bibref,
          o.OTHER_COOSYS2,
          o.Vmag,
          o.BTmag,
          o.Ty1mag,
          o.Jmag,
          o.Hmag,
          o.Ksmag
        FROM SIMBAD.OBJECT AS o
        WHERE identifier = '#{escaped}'
      ADQL
    end

    # Parse a successful base-client result and compose identity/astrometry fields.
    #
    # Preserves all base transport fields (success?, status, body, error_kind, metadata).
    # When the response is successful with a parseable JSON body, extracts informal
    # identity/astrometry fields from the TAP result columns. Empty results (zero rows)
    # return success + empty/no-match — never an error_kind.
    #
    # @param result [Astronomy::Result] the raw base-client result.
    # @return [Astronomy::Result] composed result with identity/astrometry fields.
    def parse_response(result)
      return result unless result.success?

      body = result.body
      return empty_result(result) if body.nil? || body.empty?

      parsed = parse_json(body)
      return empty_result(result) if parsed.nil? || parsed['data'].nil? || parsed['data'].empty?

      rows = parsed['data']
      first_row = rows.first

      compose_result(result, first_row, rows.length)
    end

    # Compose a result with identity/astrometry fields from the first matching row.
    #
    # @param base_result [Astronomy::Result] the original base-client result.
    # @param row [Hash] the first TAP response row (column name → value).
    # @param match_count [Integer] total number of matching rows in the response.
    # @return [Astronomy::Result] composed result with identity/astrometry fields.
    def compose_result(base_result, row, match_count)
      identifiers = extract_identifiers(row['identifier'])
      aliases = extract_aliases(row['alias'])

      coordinates = build_coordinates(row)
      astrometry = build_astrometry(row)

      base_result.metadata[:primary_id] = row['mainid'] || row['oid']
      base_result.metadata[:identifiers] = identifiers
      base_result.metadata[:aliases] = aliases
      base_result.metadata[:object_class] = row['classObj']
      base_result.metadata[:coordinates] = coordinates
      base_result.metadata[:astrometry] = astrometry
      base_result.metadata[:match_count] = match_count

      base_result
    end

    # Build an empty/no-match result from a successful base-client result.
    #
    # @param base_result [Astronomy::Result] the original base-client result.
    # @return [Astronomy::Result] with success + empty/no-match indicator.
    def empty_result(base_result)
      base_result.metadata[:primary_id] = nil
      base_result.metadata[:identifiers] = []
      base_result.metadata[:aliases] = []
      base_result.metadata[:object_class] = nil
      base_result.metadata[:coordinates] = nil
      base_result.metadata[:astrometry] = nil
      base_result.metadata[:match_count] = 0

      base_result
    end

    # Extract identifiers from a SIMBAD TAP response column.
    #
    # @param value [String, Array, nil] the identifier column value.
    # @return [Array<String>] list of identifier strings.
    def extract_identifiers(value)
      return [] if value.nil? || value.empty?

      case value
      when String
        value.split(',').map(&:strip).reject(&:empty?)
      when Array
        value.map(&:to_s).reject(&:empty?)
      else
        [value.to_s]
      end
    end

    # Extract aliases from a SIMBAD TAP response column.
    #
    # @param value [String, Array, nil] the alias column value.
    # @return [Array<String>] list of alias strings (all preserved).
    def extract_aliases(value)
      return [] if value.nil? || value.empty?

      case value
      when String
        value.split(',').map(&:strip).reject(&:empty?)
      when Array
        value.map(&:to_s).reject(&:empty?)
      else
        [value.to_s]
      end
    end

    # Build coordinates hash from SIMBAD TAP response columns.
    #
    # @param row [Hash] the TAP response row.
    # @return [Hash, nil] coordinates with ra/dec/frame/epoch or nil when unavailable.
    def build_coordinates(row)
      ra = row['ra']
      dec = row['dec']

      return nil if ra.nil? || dec.nil?

      {
        ra: parse_float(ra),
        dec: parse_float(dec),
        frame: 'ICRS',
        epoch: 2000.0
      }
    end

    # Build astrometry hash from SIMBAD TAP response columns.
    #
    # @param row [Hash] the TAP response row.
    # @return [Hash, nil] astrometry with pmRA/pmDE/mu/muPA/distPM or nil when unavailable.
    def build_astrometry(row)
      pm_ra = row['pmRA']
      pm_de = row['pmDE']

      return nil if pm_ra.nil? && pm_de.nil?

      {
        pm_ra: parse_float(pm_ra),
        pm_de: parse_float(pm_de),
        mu: parse_float(row['mu']),
        mu_pa: parse_float(row['muPA']),
        dist_pm: parse_float(row['distPM'])
      }
    end

    # Parse a JSON string from the TAP response.
    #
    # @param json_string [String] the JSON body string.
    # @return [Hash, nil] parsed JSON or nil on parse failure.
    def parse_json(json_string)
      require 'json'
      JSON.parse(json_string)
    rescue JSON::ParserError
      nil
    end

    # Parse a float value from a TAP response column.
    #
    # @param value [String, Float, Integer, nil] the raw value.
    # @return [Float, nil] parsed float or nil when the input is nil/empty.
    def parse_float(value)
      return nil if value.nil? || value.to_s.strip.empty?

      Float(value)
    rescue ArgumentError, TypeError
      nil
    end
  end
end
