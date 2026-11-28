# frozen_string_literal: true

module Astronomy
  # NASA Exoplanet Archive provider client for targeted confirmed-planet lookups.
  #
  # Delegates HTTP transport to {Astronomy::BaseTapClient} and composes
  # {Astronomy::Result} with informal planet/host parameters extracted from
  # the raw TAP response body. No provenance schema is invented here;
  # callers may interpret the raw body independently.
  #
  # Error classification (error_kind on the result) comes entirely from the
  # base client: :timeout, :unavailable, or :unsuccessful. An HTTP 2xx
  # response with zero matching rows is treated as successful transport with
  # an empty/no-match result — it does not set error_kind to unavailable.
  class NasaExoplanetArchiveClient
    # Public NASA Exoplanet Archive TAP sync base URL (free, no authentication required).
    NEA_TAP_BASE_URL = 'https://exoplanetarchive.ipac.caltech.edu/TAP'.freeze

    # @param base_client [Astronomy::BaseTapClient, nil] optional dependency-injected client;
    #   creates a new one with {NEA_TAP_BASE_URL} when omitted.
    def initialize(base_client = nil)
      @base_client = base_client || BaseTapClient.new(base_url: NEA_TAP_BASE_URL)
    end

    # Perform a targeted NASA Exoplanet Archive lookup by host star name.
    #
    # Queries the confirmed-planet table (ps) with default_flag=1 for the
    # recommended parameter set. Returns an Astronomy::Result composed of
    # base transport fields plus informal planet/host parameters when the
    # response is successful and parseable. Empty results (zero rows) return
    # success + empty/no-match — never an error_kind.
    #
    # @param hostname [String] the host star name to look up.
    #   Single quotes in the input are escaped by doubling (SQL standard).
    # @return [Astronomy::Result] composed result with base transport fields plus
    #   informal planet/host parameters when the response is successful and parseable.
    def lookup_planets(hostname)
      query = build_lookup_query(hostname)
      result = @base_client.query(path: '/sync', params: { query: query, format: 'json' })
      parse_response(result)
    end

    private

    # Build an ADQL TAP query for a targeted confirmed-planet lookup by host star name.
    # Single quotes in the input are escaped by doubling (SQL standard).
    #
    # @param hostname [String] the host star name.
    # @return [String] the ADQL query string.
    def build_lookup_query(hostname)
      escaped = hostname.to_s.gsub("'", "''")
      <<~ADQL.strip
        SELECT pl_plname, pl_hostname, ra, dec,
          pl_bmasse, pl_radem, pl_rad, pl_orbper, pl_orbsmax,
          pl_orbeccen, pl_orbincl, pl_masse, pl_massr,
          st_teff, st_logg, st_met, st_rad, st_mass,
          ra_errm, dec_errm
        FROM ps
        WHERE default_flag = 1 AND hostname = '#{escaped}'
      ADQL
    end

    # Parse a successful base-client result and compose planet/host parameters.
    #
    # Preserves all base transport fields (success?, status, body, error_kind, metadata).
    # When the response is successful with a parseable JSON body, extracts informal
    # planet/host parameters from the TAP result columns. Empty results (zero rows)
    # return success + empty/no-match — never an error_kind.
    #
    # @param result [Astronomy::Result] the raw base-client result.
    # @return [Astronomy::Result] composed result with planet/host parameters.
    def parse_response(result)
      return result unless result.success?

      body = result.body
      return empty_result(result) if body.nil? || body.empty?

      parsed = parse_json(body)
      return empty_result(result) if parsed.nil? || parsed['data'].nil? || parsed['data'].empty?

      rows = parsed['data']
      compose_result(result, rows)
    end

    # Compose a result with planet/host parameters from the matching rows.
    #
    # @param base_result [Astronomy::Result] the original base-client result.
    # @param rows [Array<Hash>] the TAP response rows (column name → value).
    # @return [Astronomy::Result] composed result with planet/host parameters.
    def compose_result(base_result, rows)
      planets = rows.map { |row| extract_planet(row) }
      host_params = extract_host(rows.first)

      base_result.metadata[:planets] = planets
      base_result.metadata[:host_parameters] = host_params
      base_result.metadata[:match_count] = rows.length

      base_result
    end

    # Extract an empty/no-match result from a successful base-client result.
    #
    # @param base_result [Astronomy::Result] the original base-client result.
    # @return [Astronomy::Result] with success + empty/no-match indicator.
    def empty_result(base_result)
      base_result.metadata[:planets] = []
      base_result.metadata[:host_parameters] = nil
      base_result.metadata[:match_count] = 0

      base_result
    end

    # Extract planet parameters from a TAP response row.
    #
    # @param row [Hash] the TAP response row (column name → value).
    # @return [Hash, nil] planet parameters or nil when no planet data is present.
    def extract_planet(row)
      return nil if row['pl_plname'].nil?

      {
        name: row['pl_plname'],
        hostname: row['pl_hostname'],
        ra: parse_float(row['ra']),
        dec: parse_float(row['dec']),
        mass_jupiter: parse_float(row['pl_bmasse']),
        radius_error: parse_float(row['pl_radem']),
        radius: parse_float(row['pl_rad']),
        orbital_period: parse_float(row['pl_orbper']),
        semimajor_axis: parse_float(row['pl_orbsmax']),
        eccentricity: parse_float(row['pl_orbeccen']),
        inclination: parse_float(row['pl_orbincl']),
        mass_earth: parse_float(row['pl_masse']),
        mass_ratio: parse_float(row['pl_massr'])
      }
    end

    # Extract host stellar parameters from a TAP response row.
    #
    # @param row [Hash, nil] the TAP response row or nil when no rows are present.
    # @return [Hash, nil] host parameters or nil when unavailable.
    def extract_host(row)
      return nil if row.nil?

      {
        teff: parse_float(row['st_teff']),
        logg: parse_float(row['st_logg']),
        metallicity: parse_float(row['st_met']),
        radius: parse_float(row['st_rad']),
        mass: parse_float(row['st_mass'])
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
