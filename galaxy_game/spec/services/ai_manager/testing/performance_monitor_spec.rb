# spec/services/ai_manager/testing/performance_monitor_spec.rb
require 'rails_helper'

RSpec.describe AIManager::Testing::PerformanceMonitor, type: :service do
  let(:performance_monitor) { described_class.new }
  let(:settlement) { create(:base_settlement) }

  describe '#start_monitoring' do
    it 'starts monitoring session' do
      session_name = performance_monitor.start_monitoring('test_session')

      expect(session_name).to eq('test_session')
      expect(performance_monitor.start_time).to be_a(Time)
    end

    it 'initializes metrics' do
      performance_monitor.start_monitoring

      expect(performance_monitor.metrics).to have_key(:total_operations)
      expect(performance_monitor.metrics[:total_operations]).to eq(0)
    end
  end

  describe '#stop_monitoring' do
    before do
      performance_monitor.start_monitoring
    end

    it 'stops monitoring and returns report' do
      report = performance_monitor.stop_monitoring

      expect(report).to be_a(Hash)
      expect(report).to have_key(:session_duration)
      expect(report).to have_key(:performance_summary)
    end

    it 'resets start time' do
      performance_monitor.stop_monitoring

      expect(performance_monitor.start_time).to be_nil
    end
  end

  describe '#record_metric' do
    before do
      performance_monitor.start_monitoring
    end

    it 'records metric with value' do
      performance_monitor.record_metric('test_metric', 42)

      snapshot = performance_monitor.current_snapshot
      expect(snapshot[:total_metrics_recorded]).to eq(1)
    end

    it 'records metric with metadata' do
      performance_monitor.record_metric('decision_time', 1.5, { complexity: 'high' })

      snapshot = performance_monitor.current_snapshot
      expect(snapshot[:recent_metrics].first[:metadata][:complexity]).to eq('high')
    end
  end

  describe '#start_operation_monitor and #end_operation_monitor' do
    before do
      performance_monitor.start_monitoring
    end

    it 'monitors operation duration' do
      performance_monitor.start_operation_monitor('test_operation')

      # Simulate some work
      sleep(0.01)

      performance_monitor.end_operation_monitor('test_operation')

      snapshot = performance_monitor.current_snapshot
      expect(snapshot[:total_metrics_recorded]).to eq(1)
      expect(snapshot[:recent_metrics].first[:name]).to eq('test_operation_duration')
    end
  end

  describe '#monitor_ai_decision' do
    before do
      performance_monitor.start_monitoring
    end

    it 'monitors AI decision making' do
      decision_data = { options: [:option1, :option2], constraints: [] }

      performance_monitor.monitor_ai_decision(settlement, decision_data)

      # Should start monitoring operation
      expect(performance_monitor.active_monitors.size).to eq(1)
    end
  end

  describe '#detect_anomalies' do
    before do
      performance_monitor.start_monitoring
    end

    it 'detects slow decision making' do
      # Record slow decisions
      6.times { performance_monitor.record_metric('decision_making_duration', 6.0) }

      anomalies = performance_monitor.detect_anomalies

      expect(anomalies.size).to eq(1)
      expect(anomalies.first[:type]).to eq(:slow_decision_making)
    end

    it 'detects high error rate' do
      # Record many errors
      15.times { performance_monitor.record_metric('error_count', 1) }

      anomalies = performance_monitor.detect_anomalies

      expect(anomalies.size).to eq(1)
      expect(anomalies.first[:type]).to eq(:high_error_rate)
    end
  end

  describe '#current_snapshot' do
    before do
      performance_monitor.start_monitoring
    end

    it 'returns current performance snapshot' do
      snapshot = performance_monitor.current_snapshot

      expect(snapshot).to have_key(:session_duration)
      expect(snapshot).to have_key(:total_metrics_recorded)
      expect(snapshot).to have_key(:aggregate_metrics)
    end
  end
end