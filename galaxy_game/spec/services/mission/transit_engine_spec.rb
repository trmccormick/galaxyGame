# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mission::TransitEngine, type: :service do
  describe '.earth_to_luna_transit_days' do
    it 'returns 7 days for Hohmann transfer Earth→Luna' do
      expect(described_class.earth_to_luna_transit_days).to eq(7)
    end
  end

  describe '.earth_to_venus_transit_days' do
    it 'returns 146 days for Hohmann transfer Earth→Venus' do
      expect(described_class.earth_to_venus_transit_days).to eq(146)
    end
  end

  describe '.earth_to_titan_transit_days' do
    it 'returns 1388 days for Earth→Titan' do
      expect(described_class.earth_to_titan_transit_days).to eq(1388)
    end
  end

  describe '.earth_to_mars_transit_days' do
    it 'returns 259 days for Earth→Mars' do
      expect(described_class.earth_to_mars_transit_days).to eq(259)
    end
  end

  describe '.luna_to_earth_transit_days' do
    it 'delegates to earth_to_luna_transit_days' do
      expect(described_class.luna_to_earth_transit_days).to eq(described_class.earth_to_luna_transit_days)
    end
  end

  describe '.luna_to_venus_transit_days' do
    it 'delegates to earth_to_venus_transit_days' do
      expect(described_class.luna_to_venus_transit_days).to eq(described_class.earth_to_venus_transit_days)
    end
  end

  describe '.luna_to_titan_transit_days' do
    it 'delegates to earth_to_titan_transit_days' do
      expect(described_class.luna_to_titan_transit_days).to eq(described_class.earth_to_titan_transit_days)
    end
  end

  describe '.luna_to_mars_transit_days' do
    it 'delegates to earth_to_mars_transit_days' do
      expect(described_class.luna_to_mars_transit_days).to eq(described_class.earth_to_mars_transit_days)
    end
  end

  describe '.calculate_transfer_window' do
    let(:launch_date) { Date.new(2030, 1, 15) }

    it 'raises for Earth→Luna (moon route rejected by Phase 1 topology containment)' do
      expect {
        described_class.calculate_transfer_window('EARTH-01', 'LUNA-01', launch_date)
      }.to raise_error(Mission::UnsupportedTransferError, /unsupported topology for legacy transfer calculation.*LUNA-01/)
    end

    it 'returns correct window for Earth→Venus' do
      result = described_class.calculate_transfer_window('EARTH-01', 'VENUS-01', launch_date)
      expect(result[:departure_date]).to eq(launch_date)
      expect(result[:arrival_date]).to eq(launch_date + 146)
      expect(result[:transit_days]).to eq(146)
    end

    it 'raises for Luna→Venus (moon route rejected by Phase 1 topology containment)' do
      expect {
        described_class.calculate_transfer_window('LUNA-01', 'VENUS-01', launch_date)
      }.to raise_error(Mission::UnsupportedTransferError, /unsupported topology for legacy transfer calculation.*LUNA-01/)
    end

    it 'raises for Earth→Titan (moon route rejected by Phase 1 topology containment)' do
      expect {
        described_class.calculate_transfer_window('EARTH-01', 'TITAN-01', launch_date)
      }.to raise_error(Mission::UnsupportedTransferError, /unsupported topology for legacy transfer calculation.*TITAN-01/)
    end

    it 'returns correct window for Earth→Mars' do
      result = described_class.calculate_transfer_window('EARTH-01', 'MARS-01', launch_date)
      expect(result[:transit_days]).to eq(259)
    end

    it 'raises for Earth→PLUTO (resolved non-planet-lineage body rejected by Phase 1 topology containment)' do
      expect {
        described_class.calculate_transfer_window('EARTH-01', 'PLUTO-01', launch_date)
      }.to raise_error(Mission::UnsupportedTransferError, /unsupported topology for legacy transfer calculation.*PLUTO-01/)
    end

    it 'uses today when no launch_date is provided' do
      today = Time.current.to_date
      result = described_class.calculate_transfer_window('EARTH-01', 'VENUS-01')
      expect(result[:departure_date]).to eq(today)
    end

    it 'is case-insensitive for body identifiers' do
      result_lower = described_class.calculate_transfer_window('earth-01', 'venus-01', launch_date)
      result_upper = described_class.calculate_transfer_window('EARTH-01', 'VENUS-01', launch_date)
      expect(result_lower[:transit_days]).to eq(result_upper[:transit_days])
    end
  end

  describe '.transfer_window_open?' do
    it 'always returns true for MVP' do
      date = Date.new(2030, 6, 15)
      expect(described_class.transfer_window_open?('EARTH-01', 'VENUS-01', date)).to be true
    end
  end

  describe '.schedule_departure' do
    let(:launch_date) { Date.new(2030, 1, 15) }

    it 'returns a transit record with correct structure' do
      record = described_class.schedule_departure('venus_harvester_01', 'EARTH-01', 'VENUS-01', launch_date)

      expect(record[:craft_id]).to eq('venus_harvester_01')
      expect(record[:status]).to eq(:in_transit)
      expect(record[:from_body]).to eq('EARTH-01')
      expect(record[:to_body]).to eq('VENUS-01')
      expect(record[:departure_date]).to eq(launch_date)
      expect(record[:arrival_date]).to eq(launch_date + 146)
      expect(record[:transit_days]).to eq(146)
      expect(record[:payload]).to be_nil
    end

    it 'raises for Titan transit (moon route rejected by Phase 1 topology containment)' do
      expect {
        described_class.schedule_departure('titan_harvester_01', 'EARTH-01', 'TITAN-01', launch_date)
      }.to raise_error(Mission::UnsupportedTransferError, /unsupported topology for legacy transfer calculation.*TITAN-01/)
    end
  end

  describe '.has_arrived?' do
    let(:launch_date) { Date.new(2030, 1, 15) }
    let(:transit_record) do
      described_class.schedule_departure('test_craft', 'EARTH-01', 'VENUS-01', launch_date)
    end

    it 'returns true when sim_day >= transit_days' do
      # Arrival is at launch_date + 146, so sim_day=146 should arrive
      expect(described_class.has_arrived?(transit_record, 146)).to be true
    end

    it 'returns false when sim_day < transit_days' do
      expect(described_class.has_arrived?(transit_record, 145)).to be false
    end

    it 'returns true for overdue arrivals' do
      expect(described_class.has_arrived?(transit_record, 200)).to be true
    end
  end

  describe '.days_remaining' do
    let(:launch_date) { Date.new(2030, 1, 15) }
    let(:transit_record) do
      described_class.schedule_departure('test_craft', 'EARTH-01', 'VENUS-01', launch_date)
    end

    it 'returns positive days when before arrival' do
      remaining = described_class.days_remaining(transit_record, 100)
      expect(remaining).to be > 0
    end

    it 'returns zero on arrival day' do
      remaining = described_class.days_remaining(transit_record, 146)
      expect(remaining).to eq(0)
    end

    it 'returns negative days when overdue' do
      remaining = described_class.days_remaining(transit_record, 200)
      expect(remaining).to be < 0
    end
  end

  describe '.can_offload_n2?' do
    it 'allows offload when tank farm is ready and sufficient tanks deployed' do
      result = described_class.can_offload_n2?(tank_farm_ready: true, tank_count: 5)
      expect(result[:allowed]).to be true
      expect(result[:reason]).to eq('All offload requirements met')
    end

    it 'denies offload when tank farm is not ready' do
      result = described_class.can_offload_n2?(tank_farm_ready: false, tank_count: 5)
      expect(result[:allowed]).to be false
      expect(result[:reason]).to include('not complete')
    end

    it 'denies offload when insufficient tanks deployed' do
      result = described_class.can_offload_n2?(tank_farm_ready: true, tank_count: 2)
      expect(result[:allowed]).to be false
      expect(result[:reason]).to include('Insufficient tanks')
    end

    it 'allows offload with exactly minimum required tanks' do
      result = described_class.can_offload_n2?(tank_farm_ready: true, tank_count: 3)
      expect(result[:allowed]).to be true
    end

    it 'accepts custom minimum_required parameter' do
      result = described_class.can_offload_n2?(tank_farm_ready: true, tank_count: 4, minimum_required: 5)
      expect(result[:allowed]).to be false
    end
  end

  describe '.compute_transit_days (internal)' do
    it 'handles case-insensitive body pairs' do
      result = described_class.compute_transit_days('earth-01', 'venus-01')
      expect(result).to eq(146)
    end

    it 'returns 365 for unknown routes' do
      result = described_class.compute_transit_days('EARTH-01', 'NEPTUNE-01')
      expect(result).to eq(365)
    end
  end

  describe 'Phase 1 topology containment' do
    include ActiveSupport::Testing::TimeHelpers

    let(:launch_date) { Date.new(2030, 1, 15) }
    let(:fragment)    { 'unsupported topology for legacy transfer calculation' }

    def calc(from, to)
      described_class.calculate_transfer_window(from, to, launch_date)
    end

    # Spec-local planet-lineage fixture. Identifiers must be UPPERCASE because the
    # engine resolves identifiers with .upcase. Each call gets its own solar system
    # unless one is passed.
    def planet(identifier, solar_system: create(:solar_system), **attrs)
      create(:terrestrial_planet, identifier: identifier, solar_system: solar_system, **attrs)
    end

    # 1
    it 'keeps an eligible parentless same-system planet pair on the existing dynamic path (characterization)' do
      expect(described_class).not_to receive(:fallback_transfer_window)
      result = calc('EARTH-01', 'VENUS-01')
      expect(result).to be_a(Hash)
      expect(result[:departure_date]).to eq(launch_date)
      # No numeric transit_days assertion: it depends on seeded orbital data.
    end

    # 2, 3
    it 'raises for planet → moon' do
      expect { calc('EARTH-01', 'LUNA-01') }
        .to raise_error(Mission::UnsupportedTransferError, /#{Regexp.escape(fragment)}.*LUNA-01/)
    end

    it 'raises for moon → planet' do
      expect { calc('LUNA-01', 'EARTH-01') }
        .to raise_error(Mission::UnsupportedTransferError, /#{Regexp.escape(fragment)}.*LUNA-01/)
    end

    # 4
    it 'raises for a resolved generic non-planet-lineage CelestialBody' do
      create(:celestial_body, identifier: 'TEST-GENERIC-01', solar_system: create(:solar_system))
      expect { calc('EARTH-01', 'TEST-GENERIC-01') }
        .to raise_error(Mission::UnsupportedTransferError, /#{Regexp.escape(fragment)}.*TEST-GENERIC-01/)
    end

    # 5
    it 'raises for a planet-lineage body that has a parent' do
      parent = planet('TEST-PARENT-01')
      planet('TEST-CHILD-01', solar_system: parent.solar_system, parent_celestial_body_id: parent.id)
      expect { calc('EARTH-01', 'TEST-CHILD-01') }
        .to raise_error(Mission::UnsupportedTransferError, /#{Regexp.escape(fragment)}.*TEST-CHILD-01/)
    end

    # 6
    it 'raises for a planet-lineage body with nil solar_system_id' do
      orphan = planet('TEST-NOSYS-01')
      orphan.update_column(:solar_system_id, nil)
      expect { calc('EARTH-01', 'TEST-NOSYS-01') }
        .to raise_error(Mission::UnsupportedTransferError, /#{Regexp.escape(fragment)}.*TEST-NOSYS-01/)
    end

    it 'raises when the solar_system association does not resolve' do
      # Stubbed for all CelestialBody instances in this example, so the first
      # resolved endpoint fails; the assertion is on the error and the fragment.
      allow_any_instance_of(CelestialBodies::CelestialBody).to receive(:solar_system).and_return(nil)
      expect { calc('EARTH-01', 'VENUS-01') }
        .to raise_error(Mission::UnsupportedTransferError, /#{Regexp.escape(fragment)}/)
    end

    # 7
    it 'raises for a resolved dwarf planet' do
      create(:dwarf_planet, identifier: 'TEST-DWARF-01')
      expect { calc('EARTH-01', 'TEST-DWARF-01') }
        .to raise_error(Mission::UnsupportedTransferError, /#{Regexp.escape(fragment)}.*TEST-DWARF-01/)
    end

    # 8
    it 'raises for a parentless planet pair in different solar systems and names both identifiers' do
      planet('TEST-SYSA-01')
      planet('TEST-SYSB-01')
      expect { calc('TEST-SYSA-01', 'TEST-SYSB-01') }
        .to raise_error(Mission::UnsupportedTransferError) { |e|
          expect(e.message).to include(fragment)
          expect(e.message).to include('TEST-SYSA-01')
          expect(e.message).to include('TEST-SYSB-01')
        }
    end

    # 9 (unknown identifier in either position)
    [%w[LUNA-01 TEST-UNKNOWN-01], %w[TEST-UNKNOWN-01 LUNA-01]].each do |from, to|
      it "raises for moon with unknown identifier (#{from} → #{to})" do
        expect { calc(from, to) }
          .to raise_error(Mission::UnsupportedTransferError, /#{Regexp.escape(fragment)}.*LUNA-01/)
      end
    end

    # 10 (unknown identifier in either position)
    [%w[EARTH-01 TEST-UNKNOWN-01], %w[TEST-UNKNOWN-01 EARTH-01]].each do |from, to|
      it "preserves the existing fallback for eligible planet with unknown identifier (#{from} → #{to})" do
        expect(described_class).to receive(:fallback_transfer_window).and_call_original
        result = calc(from, to)
        expect(result[:transit_days]).to be_a(Integer)
      end
    end

    # 11
    it 'preserves the existing fallback for unknown → unknown' do
      expect(described_class).to receive(:fallback_transfer_window).and_call_original
      result = calc('TEST-UNKNOWN-A', 'TEST-UNKNOWN-B')
      expect(result[:transit_days]).to be_a(Integer)
    end

    # 12
    it 'preserves the existing fallback values for an eligible pair with missing orbital data' do
      allow(described_class).to receive(:orbital_data).and_return(nil)

      venus = calc('EARTH-01', 'VENUS-01')
      expect(venus[:transit_days]).to eq(146)
      expect(venus[:arrival_date]).to eq(launch_date + 146)

      mars = calc('EARTH-01', 'MARS-01')
      expect(mars[:transit_days]).to eq(259)
    end

    # 13
    it 'raises Mission::UnsupportedTransferError with the stable fragment and offending identifier, returning no result' do
      result = nil
      expect { result = calc('EARTH-01', 'LUNA-01') }
        .to raise_error(Mission::UnsupportedTransferError) { |e|
          expect(e).to be_a(StandardError)
          expect(e.message).to include(fragment)
          expect(e.message).to include('LUNA-01')
        }
      expect(result).to be_nil
    end

    # 14
    it 'raises before any orbital-data, dynamic, fallback, or route-table method is reached' do
      %i[orbital_data fallback_transfer_window compute_transit_days_dynamic fallback_transit_days compute_transit_days].each do |m|
        expect(described_class).not_to receive(m)
      end

      expect { calc('EARTH-01', 'LUNA-01') }.to raise_error(Mission::UnsupportedTransferError)
      expect { calc('LUNA-01', 'TEST-UNKNOWN-01') }.to raise_error(Mission::UnsupportedTransferError)
    end

    # 15
    it 'leaves the direct legacy helpers unchanged and unguarded' do
      expect(described_class.earth_to_luna_transit_days).to eq(7)
      expect { described_class.luna_to_venus_transit_days }.not_to raise_error
      expect(described_class.luna_to_venus_transit_days).to eq(described_class.earth_to_venus_transit_days)
    end

    # 17
    it 'honors an explicit launch date independent of the host clock' do
      travel_to(Time.zone.local(2001, 2, 3)) do
        expect(calc('EARTH-01', 'VENUS-01')[:departure_date]).to eq(launch_date)
        expect { calc('EARTH-01', 'LUNA-01') }.to raise_error(Mission::UnsupportedTransferError)
      end
    end
  end

end
