module AiManager
  class PatternValidationService
    # Validates learned construction patterns against actual mission outcomes
    # Provides feedback for pattern correction and improvement

    def self.validate_tug_construction_pattern(mission_outcome, learned_pattern)
      validation_results = {
        pattern_accuracy: 0.0,
        corrections_needed: [],
        performance_metrics: {},
        recommendations: []
      }

      # Validate procurement strategy effectiveness
      procurement_validation = validate_procurement_performance(
        mission_outcome[:procurement_actual],
        learned_pattern[:procurement]
      )
      validation_results[:performance_metrics][:procurement] = procurement_validation

      # Validate construction sequencing efficiency
      sequencing_validation = validate_sequencing_performance(
        mission_outcome[:sequencing_actual],
        learned_pattern[:sequencing]
      )
      validation_results[:performance_metrics][:sequencing] = sequencing_validation

      # Validate quality assurance effectiveness
      qa_validation = validate_qa_performance(
        mission_outcome[:qa_actual],
        learned_pattern[:quality_assurance]
      )
      validation_results[:performance_metrics][:qa] = qa_validation

      # Calculate overall pattern accuracy
      validation_results[:pattern_accuracy] = calculate_overall_accuracy(
        procurement_validation,
        sequencing_validation,
        qa_validation
      )

      # Generate corrections and recommendations
      validation_results[:corrections_needed] = generate_corrections(
        validation_results[:performance_metrics]
      )

      validation_results[:recommendations] = generate_recommendations(
        validation_results[:pattern_accuracy],
        mission_outcome
      )

      validation_results
    end

    private

    def self.validate_procurement_performance(actual, learned)
      {
        material_cost_variance: calculate_cost_variance(actual[:total_cost], learned[:estimated_cost]),
        procurement_time_variance: calculate_time_variance(actual[:total_time_days], learned[:estimated_days]),
        material_availability_accuracy: calculate_availability_accuracy(actual[:materials_obtained], learned[:materials_needed]),
        supplier_reliability_score: calculate_supplier_reliability(actual[:supplier_performance])
      }
    end

    def self.validate_sequencing_performance(actual, learned)
      {
        phase_completion_variance: calculate_phase_variance(actual[:phase_durations], learned[:phase_durations]),
        dependency_satisfaction_rate: calculate_dependency_satisfaction(actual[:phase_dependencies], learned[:phase_dependencies]),
        resource_utilization_efficiency: calculate_resource_efficiency(actual[:resource_usage], learned[:resource_requirements]),
        bottleneck_identification: identify_bottlenecks(actual[:phase_delays], learned[:critical_path])
      }
    end

    def self.validate_qa_performance(actual, learned)
      {
        defect_detection_rate: calculate_defect_rate(actual[:defects_found], actual[:total_tests]),
        false_positive_rate: calculate_false_positives(actual[:false_alarms], actual[:total_tests]),
        test_coverage_achievement: calculate_test_coverage(actual[:tests_completed], learned[:required_tests]),
        rework_required_percentage: calculate_rework_percentage(actual[:rework_hours], actual[:total_construction_hours])
      }
    end

    def self.calculate_overall_accuracy(procurement, sequencing, qa)
      # Weighted average of performance metrics
      weights = { procurement: 0.4, sequencing: 0.4, qa: 0.2 }

      procurement_score = calculate_component_score(procurement)
      sequencing_score = calculate_component_score(sequencing)
      qa_score = calculate_component_score(qa)

      (procurement_score * weights[:procurement] +
       sequencing_score * weights[:sequencing] +
       qa_score * weights[:qa]).round(3)
    end

    def self.calculate_component_score(metrics)
      # Convert metrics to 0-1 scale and average
      scores = metrics.values.map do |value|
        case value
        when Numeric
          # Assume values are already in 0-1 range or need normalization
          [[value, 0].max, 1].min
        else
          0.5 # Default for non-numeric values
        end
      end

      scores.sum / scores.size.to_f
    end

    def self.generate_corrections(performance_metrics)
      corrections = []

      # Procurement corrections
      if performance_metrics[:procurement][:material_cost_variance] > 0.15
        corrections << "adjust_material_cost_estimates_upward_by_#{((performance_metrics[:procurement][:material_cost_variance] - 0.15) * 100).round(1)}_percent"
      end

      if performance_metrics[:procurement][:procurement_time_variance] > 0.20
        corrections << "increase_procurement_time_buffer_by_#{((performance_metrics[:procurement][:procurement_time_variance] - 0.20) * 100).round(1)}_percent"
      end

      # Sequencing corrections
      if performance_metrics[:sequencing][:resource_utilization_efficiency] < 0.85
        corrections << "optimize_resource_allocation_for_#{performance_metrics[:sequencing][:bottleneck_identification]}"
      end

      # QA corrections
      if performance_metrics[:qa][:defect_detection_rate] < 0.90
        corrections << "enhance_test_coverage_for_#{performance_metrics[:qa][:test_coverage_achievement]}_gap"
      end

      corrections
    end

    def self.generate_recommendations(overall_accuracy, mission_outcome)
      recommendations = []

      if overall_accuracy < 0.80
        recommendations << "comprehensive_pattern_review_required"
        recommendations << "consider_alternative_procurement_strategies"
      elsif overall_accuracy < 0.90
        recommendations << "minor_pattern_adjustments_needed"
        recommendations << "monitor_key_performance_indicators"
      else
        recommendations << "pattern_performing_well"
        recommendations << "consider_scaling_to_additional_systems"
      end

      # Context-specific recommendations
      if mission_outcome[:environmental_challenges]&.include?(:high_radiation)
        recommendations << "validate_radiation_shielding_effectiveness"
      end

      if mission_outcome[:resource_constraints]&.include?(:material_shortage)
        recommendations << "develop_alternative_material_sources"
      end

      recommendations
    end

    # Helper calculation methods
    def self.calculate_cost_variance(actual, estimated)
      return 0.0 if estimated.zero?
      ((actual - estimated).abs / estimated).round(3)
    end

    def self.calculate_time_variance(actual, estimated)
      return 0.0 if estimated.zero?
      ((actual - estimated).abs / estimated).round(3)
    end

    def self.calculate_availability_accuracy(obtained, needed)
      return 1.0 if needed.empty?
      (obtained & needed).size / needed.size.to_f
    end

    def self.calculate_supplier_reliability(performance_data)
      return 0.5 if performance_data.empty?
      performance_data.values.sum / performance_data.size.to_f
    end

    def self.calculate_phase_variance(actual_durations, learned_durations)
      return 0.0 if learned_durations.empty?
      variances = actual_durations.zip(learned_durations).map do |actual, learned|
        calculate_time_variance(actual, learned)
      end
      variances.sum / variances.size.to_f
    end

    def self.calculate_dependency_satisfaction(actual_deps, learned_deps)
      return 1.0 if learned_deps.empty?
      satisfied = actual_deps.count { |dep| learned_deps.include?(dep) }
      satisfied / learned_deps.size.to_f
    end

    def self.calculate_resource_efficiency(actual_usage, learned_reqs)
      return 1.0 if learned_reqs.empty?
      efficiency_scores = learned_reqs.map do |resource, required|
        actual = actual_usage[resource] || 0
        next 0.0 if required.zero?
        efficiency = 1.0 - ((actual - required).abs / required)
        [efficiency, 0].max # Don't go below 0
      end
      efficiency_scores.sum / efficiency_scores.size.to_f
    end

    def self.identify_bottlenecks(delays, critical_path)
      return "unknown" if delays.empty? || critical_path.empty?
      # Find phases with delays above threshold
      bottleneck_phases = delays.select { |phase, delay| delay > 24 } # 24 hours threshold
      bottleneck_phases.keys.first || "no_significant_bottlenecks"
    end

    def self.calculate_defect_rate(defects_found, total_tests)
      return 0.0 if total_tests.zero?
      defects_found / total_tests.to_f
    end

    def self.calculate_false_positives(false_alarms, total_tests)
      return 0.0 if total_tests.zero?
      false_alarms / total_tests.to_f
    end

    def self.calculate_test_coverage(tests_completed, required_tests)
      return 1.0 if required_tests.empty?
      (tests_completed & required_tests).size / required_tests.size.to_f
    end

    def self.calculate_rework_percentage(rework_hours, total_hours)
      return 0.0 if total_hours.zero?
      rework_hours / total_hours.to_f
    end
  end
end