# LegacyPortAdapter — Option C Bridge Implementation (ADR-001)
# ============================================================================
# This adapter bridges legacy port-counting schemas with v1.9 Bus-Topology connection_schema.
# Per PORT_CONNECTION_SYSTEM.md, it handles:
#   1. Detection of v1.9 connection_schema presence → use native connectivity
#   2. Projection of legacy flat ports (internal_unit_ports, storage_ports, etc.) to bus topology
#   3. Native reading of pre-v1.9 typed schemas (inflatable_gas_storage's input/output/utility_ports)
#   4. Zero-port handling for port-less units (pressure tanks, bulk storage)

require_relative 'blueprint_lookup_service'

module Lookup
  class LegacyPortAdapter < BlueprintLookupService
    # Schema version constants
    V1_9_SCHEMA_KEY = 'connection_schema'
    
    # Legacy flat port categories (typed counts per PORT_CONNECTION_SYSTEM.md)
    LEGACY_PORT_CATEGORIES = [
      'internal_unit_ports',   # Standard unit-to-unit connections
      'external_unit_ports',   # External module interfaces  
      'propulsion_ports',      # Engine/thruster attachments
      'rig_ports',             # Rig/tool mounting points
      'storage_ports'          # Storage bay interfaces
    ].freeze
    
    # Pre-v1.9 typed port types (from inflatable_gas_storage schema)
    TYPED_PORT_TYPES = ['fluid_in', 'fluid_out', 'power', 'control'].freeze

    def initialize
      super
      @migration_log_file = Rails.root.join('log', 'port_migration.log')
    end

    # ============================================================================
    # PUBLIC API — Schema Detection & Projection (per ADR-001)
    # ============================================================================

    # Detect schema version and return appropriate port representation
    # Returns: Hash with :schema_version, :ports_hash, :connection_schema keys
    def resolve_port_schema(blueprint_id_or_bp)
      blueprint = case blueprint_id_or_bp
                  when String then find_blueprint(blueprint_id_or_bp) || {}
                  when Hash   then blueprint_id_or_bp
                  else {}
                  end

      return { schema_version: 'unknown', ports_hash: {}, connection_schema: nil } if blueprint.empty?

      # DETECTION: Check for v1.9 connection_schema presence (ADR-001 Logic Requirement 1)
      if blueprint.key?(V1_9_SCHEMA_KEY) && !blueprint[V1_9_SCHEMA_KEY].nil?
        { 
          schema_version: 'v1.9',
          ports_hash: project_v1_9_to_legacy(blueprint),
          connection_schema: blueprint[V1_9_SCHEMA_KEY]
        }
      # LEGACY FLAT PORTS: Check for typed-count port categories (cryo tank style)
      elsif has_legacy_flat_ports?(blueprint)
        { 
          schema_version: 'legacy_flat',
          ports_hash: extract_legacy_flat_ports(blueprint),
          connection_schema: nil
        }
      # PRE-V1.9 TYPED PORTS: Check for input/output/utility structure (gas storage style)
      elsif has_typed_port_structure?(blueprint)
        { 
          schema_version: 'pre_v1.9_typed',
          ports_hash: extract_typed_ports(blueprint),
          connection_schema: nil
        }
      # ZERO-PORT UNITS: No port structure present (pressure tank style — GOTCHA 2)
      else
        log_migration_needed(blueprint['id'] || 'unknown', :zero_port_unit, "No ports defined")
        { 
          schema_version: 'none',
          ports_hash: {},
          connection_schema: nil
        }
      end
    rescue => e
      Rails.logger.error "LegacyPortAdapter#resolve_port_schema error for #{blueprint_id_or_bp}: #{e.message}"
      { schema_version: 'error', ports_hash: {}, connection_schema: nil }
    end

    # Get total available port count for a specific category (legacy engine compatibility)
    def get_legacy_port_count(blueprint, category = nil)
      resolved = resolve_port_schema(blueprint)
      
      return 0 if resolved[:schema_version] == 'none' || !resolved[:ports_hash].is_a?(Hash)

      # If no specific category requested and we have a flat ports block, sum all categories
      if category.nil? && resolved[:schema_version] == 'legacy_flat'
        return resolved[:ports_hash].values.sum
      end
      
      # Return count for specific category or 0
      resolved[:ports_hash][category.to_sym] || 
      resolved[:ports_hash][category&.to_s] || 
      0
    rescue => e
      Rails.logger.error "LegacyPortAdapter#get_legacy_port_count error: #{e.message}"
      0
    end

    # Check if a unit has any ports available (for connection validation)
    def has_available_ports?(blueprint, category = nil)
      get_legacy_port_count(blueprint, category) > 0
    end

    # ============================================================================
    # PRIVATE — Schema Projection Logic
    # ============================================================================

    private

    # Check if blueprint uses v1.9 connection_schema (ADR-001 Detection step)
    def has_v1_9_schema?(blueprint)
      blueprint.key?(V1_9_SCHEMA_KEY) && !blueprint[V1_9_SCHEMA_KEY].nil?
    end

    # Check for legacy flat port structure (GOTCHA 4: these should be removed after migration)
    # IMPORTANT: Must check BOTH nested ports (blueprint['ports'][category]) AND top-level (blueprint[category])
    # because older blueprints have ports at the top level (e.g., "internal_unit_ports": 4)
    def has_legacy_flat_ports?(blueprint)
      LEGACY_PORT_CATEGORIES.any? do |category|
        # Check nested ports first (canonical style per task_execution_engine_v2.rb)
        nested = blueprint.dig('ports', category).to_i > 0
        # Then check top-level (backward compatibility for legacy blueprints)
        toplevel = blueprint[category].to_i > 0
        nested || toplevel
      end
    rescue => e
      Rails.logger.error "Error checking legacy flat ports: #{e.message}"
      false
    end

    # Check for pre-v1.9 typed port structure (GOTCHA 1: gas storage style, stays as-is)
    def has_typed_port_structure?(blueprint)
      blueprint['ports'].is_a?(Hash) && 
        ['input_ports', 'output_ports', 'utility_ports'].any? { |key| blueprint.dig('ports', key).present? }
    rescue => e
      Rails.logger.error "Error checking typed port structure: #{e.message}"
      false
    end

    # Extract legacy flat ports into normalized hash (for backward compatibility)
    def extract_legacy_flat_ports(blueprint)
      ports_hash = {}
      
      # Nested under 'ports' key (canonical blueprint style per task_execution_engine_v2.rb fix)
      if blueprint['ports'].is_a?(Hash)
        LEGACY_PORT_CATEGORIES.each do |category|
          count = blueprint.dig('ports', category).to_i
          ports_hash[category.to_sym] = count if count > 0
        end
        
        # Also check top-level for legacy files not yet migrated (backward compat fallback)
        LEGACY_PORT_CATEGORIES.each do |category|
          unless ports_hash.key?(category.to_sym)
            count = blueprint[category].to_i rescue 0
            ports_hash[category.to_sym] = count if count > 0
          end
        end
        
        return ports_hash
      end
      
      # Top-level only (legacy style, should be rare after v2 fix)
      LEGACY_PORT_CATEGORIES.each do |category|
        count = blueprint[category].to_i rescue 0
        ports_hash[category.to_sym] = count if count > 0
      end
      
      ports_hash
    rescue => e
      Rails.logger.error "Error extracting legacy flat ports: #{e.message}"
      {}
    end

    # Extract typed port structure (GOTCHA 1: gas storage stays as-is, adapter reads natively)
    def extract_typed_ports(blueprint)
      return {} unless blueprint['ports'].is_a?(Hash)
      
      ports_hash = {
        input_ports: Array(blueprint.dig('ports', 'input_ports')).size,
        output_ports: Array(blueprint.dig('ports', 'output_ports')).size,
        utility_ports: Array(blueprint.dig('ports', 'utility_ports')).size
      }
      
      # Filter to non-zero counts only (zero-port units are valid per GOTCHA 2)
      ports_hash.select { |_, count| count > 0 }
    rescue => e
      Rails.logger.error "Error extracting typed ports: #{e.message}"
      {}
    end

    # Project v1.9 connection_schema to legacy port hash (for backward compatibility queries)
    def project_v1_9_to_legacy(blueprint)
      schema = blueprint[V1_9_SCHEMA_KEY] || return({})
      
      ports_hash = {
        mounting_slots: Array(schema['mounting_slots'] || []).size,
        utility_ports: Array(schema['utility_ports'] || []).size,
        storage_bays: Array(schema['storage_bays'] || []).size
      }
      
      # Map bus connections to legacy categories (approximation for compatibility)
      if schema.key?('bus_connections') && schema['bus_connections'].is_a?(Hash)
        ports_hash[:internal_unit_ports] = 
          [schema.dig('bus_connections', 'power').to_i, 
           schema.dig('bus_connections', 'data').to_i].sum
      end
      
      ports_hash.select { |_, count| count > 0 } || {}
    rescue => e
      Rails.logger.error "Error projecting v1.9 to legacy: #{e.message}"
      {}
    end

    # Log migration needed entries (ADR-001 Lifecycle Flagging requirement)
    def log_migration_needed(blueprint_id, reason, details = '')
      return unless @migration_log_file
      
      begin
        timestamp = Time.current.iso8601
        entry = "[#{timestamp}] #{blueprint_id}: #{reason} — #{details}\n"
        
        File.open(@migration_log_file, 'a') do |f|
          f.write(entry)
        end
        
        Rails.logger.info "Migration needed logged: #{blueprint_id} (#{reason})"
      rescue => e
        # Silently fail logging to avoid breaking core functionality
        Rails.logger.warn "Failed to log migration need for #{blueprint_id}: #{e.message}"
      end
    end

  end
end
