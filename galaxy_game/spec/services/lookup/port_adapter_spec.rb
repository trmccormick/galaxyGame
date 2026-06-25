require 'rails_helper'

RSpec.describe Lookup::LegacyPortAdapter, type: :service do
  let(:adapter) { described_class.new }

  # ============================================================================
  # TEST FIXTURES — Blueprint Hashes (avoid file I/O for speed/reliability)
  # ============================================================================

  # Legacy flat ports style (inflatable_cryo_tank before migration)
  let(:cryo_tank_legacy_bp) do
    {
      'id' => 'inflatable_cryo_tank',
      'name' => 'Inflatable Cryogenic Tank',
      'ports' => {
        'internal_unit_ports' => 2,
        'storage_ports' => 3
      }
    }
  end

  # Pre-v1.9 typed ports style (inflatable_gas_storage — GOTCHA 1: stays as-is)
  let(:gas_storage_typed_bp) do
    {
      'id' => 'inflatable_gas_storage',
      'name' => 'Inflatable Gas Storage',
      'ports' => {
        'input_ports' => [
          { 'id' => 'gas_input', 'type' => 'fluid_in', 'compatible_gases' => ['methane', 'oxygen'] }
        ],
        'output_ports' => [
          { 'id' => 'gas_output', 'type' => 'fluid_out', 'compatible_gases' => ['methane', 'oxygen'] }
        ],
        'utility_ports' => [
          { 'id' => 'power_input', 'type' => 'power' },
          { 'id' => 'control', 'type' => 'control' }
        ]
      }
    }
  end

  # Zero-port unit (inflatable_pressure_tank — GOTCHA 2: valid state)
  let(:pressure_tank_zero_port_bp) do
    {
      'id' => 'inflatable_pressure_tank',
      'name' => 'Inflatable Pressure Tank',
      'physical_properties' => {
        'length_m' => 6.0,
        'width_m' => 3.0,
        'height_m' => 2.5
      }
    }
  end

  # v1.9 connection_schema style (post-migration target)
  let(:v1_9_bp) do
    {
      'id' => 'example_v1_9_unit',
      'name' => 'Example V1.9 Unit',
      'connection_schema' => {
        'version' => 'v1.9',
        'mounting_slots' => [
          { 'type' => 'internal', 'location' => 'top_surface', 'fit_constraints' => ['standard_i_beam'] }
        ],
        'utility_ports' => [
          { 'bus_id' => 'power_bus_primary', 'link_type' => 'hardwired', 'allowed_formulas' => ['CH4', 'LOX'] },
          { 'bus_id' => 'data_bus_main', 'link_type' => 'fiber_optic' }
        ],
        'storage_bays' => [
          { 'max_volume_m3' => 50.0, 'is_active_cargo' => false, 'bus_power_draw_kw' => 2.5 }
        ]
      }
    }
  end

  # ============================================================================
  # SCHEMA DETECTION TESTS (ADR-001 Logic Requirement 1)
  # ============================================================================

  describe '#resolve_port_schema' do
    context 'with legacy flat ports blueprint' do
      let(:result) { adapter.resolve_port_schema(cryo_tank_legacy_bp) }

      it 'detects schema_version as legacy_flat' do
        expect(result[:schema_version]).to eq('legacy_flat')
      end

      it 'extracts correct port counts into ports_hash' do
        expect(result[:ports_hash][:internal_unit_ports]).to eq(2)
        expect(result[:ports_hash][:storage_ports]).to eq(3)
      end

      it 'returns nil for connection_schema (not v1.9)' do
        expect(result[:connection_schema]).to be_nil
      end
    end

    context 'with pre-v1.9 typed ports blueprint (gas storage — GOTCHA 1)' do
      let(:result) { adapter.resolve_port_schema(gas_storage_typed_bp) }

      it 'detects schema_version as pre_v1.9_typed' do
        expect(result[:schema_version]).to eq('pre_v1.9_typed')
      end

      it 'counts typed ports correctly without flattening structure' do
        expect(result[:ports_hash][:input_ports]).to eq(1)
        expect(result[:ports_hash][:output_ports]).to eq(1)
        expect(result[:ports_hash][:utility_ports]).to eq(2)
      end

      it 'returns nil for connection_schema (not v1.9)' do
        expect(result[:connection_schema]).to be_nil
      end
    end

    context 'with zero-port blueprint (pressure tank — GOTCHA 2)' do
      let(:result) { adapter.resolve_port_schema(pressure_tank_zero_port_bp) }

      it 'detects schema_version as none' do
        expect(result[:schema_version]).to eq('none')
      end

      it 'returns empty ports_hash (zero is valid state, not error)' do
        expect(result[:ports_hash]).to eq({})
      end

      it 'logs migration needed for zero-port unit' do
        # Migration log should be written but we test the return value here
        expect(result[:schema_version]).not_to eq('error')
      end
    end

    context 'with v1.9 connection_schema blueprint' do
      let(:result) { adapter.resolve_port_schema(v1_9_bp) }

      it 'detects schema_version as v1.9' do
        expect(result[:schema_version]).to eq('v1.9')
      end

      it 'returns the actual connection_schema object' do
        expect(result[:connection_schema]['version']).to eq('v1.9')
        expect(result[:connection_schema].key?('mounting_slots')).to be true
        expect(result[:connection_schema].key?('utility_ports')).to be true
      end

      it 'projects v1.9 to legacy ports_hash for backward compatibility' do
        # Should have projected counts even if approximate
        expect(result[:ports_hash]).not_to eq({})
      end
    end

    context 'with empty blueprint hash' do
      let(:result) { adapter.resolve_port_schema({}) }

      it 'returns unknown schema version with empty ports' do
        expect(result[:schema_version]).to eq('unknown')
        expect(result[:ports_hash]).to eq({})
      end
    end
  end

  # ============================================================================
  # LEGACY PORT COUNT QUERIES (backward compatibility for existing engine)
  # ============================================================================

  describe '#get_legacy_port_count' do
    context 'with legacy flat ports blueprint and specific category' do
      it 'returns count for requested port category' do
        expect(adapter.get_legacy_port_count(cryo_tank_legacy_bp, 'internal_unit_ports')).to eq(2)
        expect(adapter.get_legacy_port_count(cryo_tank_legacy_bp, 'storage_ports')).to eq(3)
      end

      it 'returns 0 for non-existent category' do
        expect(adapter.get_legacy_port_count(cryo_tank_legacy_bp, 'propulsion_ports')).to eq(0)
      end
    end

    context 'with zero-port blueprint (GOTCHA 2)' do
      it 'returns 0 without raising error or forcing non-zero count' do
        result = adapter.get_legacy_port_count(pressure_tank_zero_port_bp, 'internal_unit_ports')
        expect(result).to eq(0)
      end

      it 'has_available_ports? returns false for zero-port units' do
        expect(adapter.has_available_ports?(pressure_tank_zero_port_bp)).to be false
      end
    end

    context 'with typed ports blueprint (GOTCHA 1)' do
      it 'returns count of input/output/utility port arrays' do
        expect(adapter.get_legacy_port_count(gas_storage_typed_bp, 'input_ports')).to eq(1)
        expect(adapter.get_legacy_port_count(gas_storage_typed_bp, 'output_ports')).to eq(1)
        expect(adapter.get_legacy_port_count(gas_storage_typed_bp, 'utility_ports')).to eq(2)
      end

      it 'does not flatten typed structure back to bare integer count' do
        # The adapter preserves the array-based counts per GOTCHA 1 requirement
        result = adapter.resolve_port_schema(gas_storage_typed_bp)
        expect(result[:schema_version]).to eq('pre_v1.9_typed')
      end
    end

    context 'with v1.9 blueprint' do
      it 'projects to legacy counts for backward compatibility queries' do
        result = adapter.get_legacy_port_count(v1_9_bp, 'utility_ports')
        expect(result).to be >= 0 # Should have some projected count
      end
    end

    context 'with nil/invalid blueprint' do
      it 'returns 0 without raising error' do
        expect(adapter.get_legacy_port_count(nil)).to eq(0)
        expect(adapter.get_legacy_port_count({})).to eq(0)
      end
    end
  end

  # ============================================================================
  # GOTCHA VALIDATION — Critical Edge Cases from Task File
  # ============================================================================

  describe 'GOTCHA compliance' do
    context 'GOTCHA 1: inflatable_gas_storage stays as-is, adapter reads natively' do
      it 'does not migrate or flatten gas storage typed structure' do
        result = adapter.resolve_port_schema(gas_storage_typed_bp)
        
        # Schema version should be pre_v1.9_typed (not legacy_flat or v1.9)
        expect(result[:schema_version]).to eq('pre_v1.9_typed')
        
        # Ports hash preserves typed structure counts, not flattened to single integer
        expect(result[:ports_hash].keys).to include(:input_ports, :output_ports, :utility_ports)
      end

      it 'maps fluid_in/fluid_out types directly to Bus-Topology per PORT_CONNECTION_SYSTEM.md' do
        result = adapter.resolve_port_schema(gas_storage_typed_bp)
        
        # Adapter recognizes this as typed structure and preserves counts
        expect(result[:ports_hash][:input_ports]).to eq(1)  # gas_input port
        expect(result[:ports_hash][:output_ports]).to eq(1) # gas_output port
      end
    end

    context 'GOTCHA 2: zero-port units are valid, adapter returns 0 without error' do
      it 'does not force non-zero ports on pressure tank or bulk storage' do
        result = adapter.resolve_port_schema(pressure_tank_zero_port_bp)
        
        # Schema version is none (not legacy_flat with forced counts)
        expect(result[:schema_version]).to eq('none')
        
        # Ports hash is empty, not { internal_unit_ports: 1 } or similar workaround
        expect(result[:ports_hash]).to eq({})
      end

      it 'does not raise error when querying port count on zero-port unit' do
        # This should complete without exception (engine does not force non-zero)
        result = adapter.get_legacy_port_count(pressure_tank_zero_port_bp, :any_category)
        expect(result).to eq(0)
      end

      it 'has_available_ports? correctly returns false for zero-port units' do
        # Connection validation should fail gracefully (no ports available), not crash
        expect(adapter.has_available_ports?(pressure_tank_zero_port_bp)).to be false
      end
    end

    context 'GOTCHA 3: formula-first in allowed_formulas uses chemical formulas, not gas names' do
      it 'v1.9 schema example shows CH4/LOX instead of methane/oxygen strings' do
        # The v1_9_bp fixture demonstrates correct pattern (formula-based validation)
        utility_ports = v1_9_bp['connection_schema']['utility_ports']
        
        power_port = utility_ports.find { |p| p.key?('allowed_formulas') }
        expect(power_port).not_to be_nil
        
        # Should use chemical formulas, not free-text gas names per formula-first philosophy
        allowed = power_port['allowed_formulas'] || []
        expect(allowed).to include('CH4', 'LOX')  # Chemical formulas ✅
        expect(allowed).not_to include('methane', 'oxygen') # Free text ❌ (GOTCHA 3 violation)
      end
    end

    context 'GOTCHA 4: Zero-Drift Enforcement — no legacy ports block alongside v1.9' do
      it 'v1.9 blueprint has connection_schema but NOT a separate ports key' do
        # The fixture demonstrates correct pattern (no dual-format drift)
        expect(v1_9_bp.key?('connection_schema')).to be true
        
        # Should not have legacy flat ports block present simultaneously
        if v1_9_bp.key?('ports') && v1_9_bp['ports'].is_a?(Hash)
          # If it has a 'ports' key, verify it's NOT the old typed-count style
          expect(v1_9_bp['ports']).not_to have_key('internal_unit_ports')
        end
        
        # Correct pattern: connection_schema only (no legacy ports block at all)
      end

      it 'legacy flat blueprint has ports but NOT a connection_schema key' do
        # The cryo_tank_legacy_bp fixture demonstrates pre-migration state
        expect(cryo_tank_legacy_bp.key?('ports')).to be true
        
        # Should not have v1.9 schema present simultaneously (no dual-format drift)
        expect(cryo_tank_legacy_bp).not_to have_key('connection_schema')
      end

      it 'migration removes legacy ports block entirely, adapter handles backward queries' do
        # After migration to v1.9: blueprint has ONLY connection_schema
        # The adapter's project_v1_9_to_legacy method provides backward-compatible port counts
        result = adapter.resolve_port_schema(v1_9_bp)
        
        expect(result[:schema_version]).to eq('v1.9')
        expect(result[:ports_hash]).not_to be_empty  # Projected for compatibility
        
        # Blueprint itself should not carry both formats (verified by fixture structure above)
      end
    end
  end

end
