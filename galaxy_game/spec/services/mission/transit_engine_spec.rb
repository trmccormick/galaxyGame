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

    it 'returns correct window for Earth→Luna' do
      result = described_class.calculate_transfer_window('EARTH-01', 'LUNA-01', launch_date)
      expect(result[:departure_date]).to eq(launch_date)
      expect(result[:arrival_date]).to eq(launch_date + 7)
      expect(result[:transit_days]).to eq(7)
    end

    it 'returns correct window for Earth→Venus' do
      result = described_class.calculate_transfer_window('EARTH-01', 'VENUS-01', launch_date)
      expect(result[:departure_date]).to eq(launch_date)
      expect(result[:arrival_date]).to eq(launch_date + 146)
      expect(result[:transit_days]).to eq(146)
    end

    it 'returns correct window for Luna→Venus' do
      result = described_class.calculate_transfer_window('LUNA-01', 'VENUS-01', launch_date)
      expect(result[:transit_days]).to eq(146)
    end

    it 'returns correct window for Earth→Titan' do
      result = described_class.calculate_transfer_window('EARTH-01', 'TITAN-01', launch_date)
      expect(result[:transit_days]).to eq(1388)
      expect(result[:arrival_date]).to eq(launch_date + 1388)
    end

    it 'returns correct window for Earth→Mars' do
      result = described_class.calculate_transfer_window('EARTH-01', 'MARS-01', launch_date)
      expect(result[:transit_days]).to eq(259)
    end

    it 'defaults to 365 days for unknown routes' do
      result = described_class.calculate_transfer_window('EARTH-01', 'PLUTO-01', launch_date)
      expect(result[:transit_days]).to eq(365)
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

    it 'handles Titan transit' do
      record = described_class.schedule_departure('titan_harvester_01', 'EARTH-01', 'TITAN-01', launch_date)
      expect(record[:transit_days]).to eq(1388)
      expect(record[:status]).to eq(:in_transit)
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
end
