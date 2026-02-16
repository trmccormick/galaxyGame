# app/services/ai_manager/testing/performance_monitor.rb
module AIManager
  module Testing
    class PerformanceMonitor
      attr_reader :metrics, :start_time, :active_monitors

      def initialize
        @metrics = {}
        @start_time = nil
        @active_monitors = []
        @performance_data = []
      end

      # Start performance monitoring session
      def start_monitoring(session_name = 'ai_test_session')
        @start_time = Time.current
        @metrics = {}
        @performance_data = []
        @active_monitors = []

        Rails.logger.info "[PerformanceMonitor] Started monitoring session: #{session_name}"

        # Initialize core metrics
        initialize_core_metrics

        session_name
      end

      # Stop monitoring and return performance report
      def stop_monitoring
        return nil unless @start_time

        end_time = Time.current
        duration = end_time - @start_time

        report = generate_performance_report(duration)

        Rails.logger.info "[PerformanceMonitor] Stopped monitoring session (#{duration.round(2)}s)"

        # Reset state
        @start_time = nil
        @active_monitors = []

        report
      end

      # Record a performance metric
      def record_metric(metric_name, value, metadata = {})
        return unless @start_time

        timestamp = Time.current
        elapsed = timestamp - @start_time

        metric_data = {
          name: metric_name,
          value: value,
          timestamp: timestamp,
          elapsed_time: elapsed,
          metadata: metadata
        }

        @performance_data << metric_data

        # Update aggregate metrics
        update_aggregate_metric(metric_name, value)

        Rails.logger.debug "[PerformanceMonitor] Recorded metric: #{metric_name} = #{value}"
      end

      # Start monitoring a specific operation
      def start_operation_monitor(operation_name)
        return unless @start_time

        operation_start = {
          name: operation_name,
          start_time: Time.current,
          elapsed_start: Time.current - @start_time
        }

        @active_monitors << operation_start

        Rails.logger.debug "[PerformanceMonitor] Started monitoring operation: #{operation_name}"
      end

      # End monitoring a specific operation
      def end_operation_monitor(operation_name)
        return unless @start_time

        operation = @active_monitors.find { |op| op[:name] == operation_name }
        return unless operation

        end_time = Time.current
        duration = end_time - operation[:start_time]

        record_metric("#{operation_name}_duration", duration,
                     { operation_type: :timed_operation, start_time: operation[:start_time] })

        @active_monitors.delete(operation)

        Rails.logger.debug "[PerformanceMonitor] Ended monitoring operation: #{operation_name} (#{duration.round(3)}s)"
      end

      # Monitor AI decision making performance
      def monitor_ai_decision(settlement, decision_data)
        return unless @start_time

        start_operation_monitor('ai_decision_making')

        # Record decision context
        record_metric('decision_context_complexity', calculate_decision_complexity(decision_data))
        record_metric('available_options_count', decision_data[:options]&.size || 0)

        # This would be called after the decision is made
        # The actual timing is handled by start/end_operation_monitor
      end

      # Monitor service orchestration performance
      def monitor_service_orchestration(operation_type, service_count)
        return unless @start_time

        operation_name = "service_orchestration_#{operation_type}"
        start_operation_monitor(operation_name)

        record_metric('services_coordinated', service_count)
        record_metric('orchestration_type', operation_type.to_s)

        # End monitoring would be called after orchestration completes
      end

      # Get current performance snapshot
      def current_snapshot
        return {} unless @start_time

        elapsed = Time.current - @start_time

        {
          session_duration: elapsed,
          total_metrics_recorded: @performance_data.size,
          active_operations: @active_monitors.size,
          aggregate_metrics: @metrics,
          recent_metrics: @performance_data.last(10)
        }
      end

      # Check for performance anomalies
      def detect_anomalies
        return [] unless @performance_data.size > 10

        anomalies = []

        # Check for decision making taking too long
        decision_durations = @performance_data.select { |m| m[:name].include?('decision_making_duration') }
        if decision_durations.any?
          avg_duration = decision_durations.sum { |d| d[:value] } / decision_durations.size
          if avg_duration > 5.0 # 5 seconds threshold
            anomalies << {
              type: :slow_decision_making,
              severity: :warning,
              message: "Average decision time #{avg_duration.round(2)}s exceeds 5s threshold",
              data: { average_duration: avg_duration, sample_count: decision_durations.size }
            }
          end
        end

        # Check for high error rates
        error_metrics = @performance_data.select { |m| m[:name].include?('error') }
        if error_metrics.size > @performance_data.size * 0.1 # 10% error rate
          anomalies << {
            type: :high_error_rate,
            severity: :error,
            message: "Error rate #{(error_metrics.size.to_f / @performance_data.size * 100).round(1)}% exceeds 10% threshold",
            data: { error_count: error_metrics.size, total_metrics: @performance_data.size }
          }
        end

        # Check for service overload
        service_loads = @performance_data.select { |m| m[:name].include?('service_load') }
        if service_loads.any?
          max_load = service_loads.max_by { |m| m[:value] }[:value]
          if max_load > 0.9 # 90% load threshold
            anomalies << {
              type: :service_overload,
              severity: :warning,
              message: "Service load #{(max_load * 100).round(1)}% exceeds 90% threshold",
              data: { max_load: max_load }
            }
          end
        end

        anomalies
      end

      private

      # Initialize core performance metrics
      def initialize_core_metrics
        @metrics = {
          total_operations: 0,
          average_decision_time: 0,
          error_count: 0,
          service_coordination_events: 0,
          resource_operations: 0,
          scouting_operations: 0
        }
      end

      # Update aggregate metrics
      def update_aggregate_metric(metric_name, value)
        case metric_name
        when /_duration$/
          # Update timing metrics
          if metric_name.include?('decision')
            update_decision_timing_metrics(value)
          end
        when /error/
          @metrics[:error_count] += 1
        when /service_coordination/
          @metrics[:service_coordination_events] += 1
        when /resource/
          @metrics[:resource_operations] += 1
        when /scouting/
          @metrics[:scouting_operations] += 1
        end

        @metrics[:total_operations] += 1
      end

      # Update decision timing metrics
      def update_decision_timing_metrics(duration)
        current_avg = @metrics[:average_decision_time]
        total_decisions = @metrics[:total_operations]

        # Running average calculation
        @metrics[:average_decision_time] = (current_avg * (total_decisions - 1) + duration) / total_decisions
      end

      # Calculate decision complexity based on available data
      def calculate_decision_complexity(decision_data)
        complexity = 0

        # Factor in number of options
        complexity += (decision_data[:options]&.size || 0) * 0.1

        # Factor in resource constraints
        complexity += (decision_data[:resource_constraints]&.size || 0) * 0.2

        # Factor in strategic factors
        complexity += (decision_data[:strategic_factors]&.size || 0) * 0.3

        # Factor in time pressure
        complexity += decision_data[:time_pressure] ? 0.5 : 0

        complexity
      end

      # Generate comprehensive performance report
      def generate_performance_report(duration)
        anomalies = detect_anomalies

        {
          session_duration: duration,
          total_metrics: @performance_data.size,
          aggregate_metrics: @metrics,
          anomalies_detected: anomalies.size,
          anomalies: anomalies,
          performance_summary: {
            operations_per_second: @metrics[:total_operations] / duration,
            average_decision_time: @metrics[:average_decision_time],
            error_rate: @metrics[:error_count].to_f / @metrics[:total_operations] * 100,
            service_coordination_rate: @metrics[:service_coordination_events] / duration
          },
          recommendations: generate_recommendations(anomalies)
        }
      end

      # Generate performance recommendations
      def generate_recommendations(anomalies)
        recommendations = []

        anomalies.each do |anomaly|
          case anomaly[:type]
          when :slow_decision_making
            recommendations << "Consider optimizing decision-making algorithms - current average #{anomaly[:data][:average_duration].round(2)}s"
          when :high_error_rate
            recommendations << "Investigate error sources - #{anomaly[:data][:error_count]} errors in #{anomaly[:data][:total_metrics]} operations"
          when :service_overload
            recommendations << "Scale up service capacity or optimize load balancing - peak load #{(anomaly[:data][:max_load] * 100).round(1)}%"
          end
        end

        recommendations.empty? ? ["Performance within acceptable parameters"] : recommendations
      end
    end
  end
end