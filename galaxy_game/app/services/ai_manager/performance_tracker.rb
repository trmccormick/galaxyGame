module AIManager
  class PerformanceTracker
    attr_reader :settlement_id, :decision_history, :pattern_performance

    def initialize(settlement_id)
      @settlement_id = settlement_id
      @decision_history = []
      @pattern_performance = {}
      @adaptation_rules = load_adaptation_rules
      load_existing_performance_data
    end

    def record_decision(decision, context)
      decision_record = {
        timestamp: Time.current,
        decision: decision,
        context: context,
        outcome: nil,
        success_score: nil,
        lessons_learned: []
      }

      @decision_history << decision_record

      # Track pattern usage
      if decision[:pattern]
        @pattern_performance[decision[:pattern]] ||= { uses: 0, successes: 0, avg_score: 0 }
        @pattern_performance[decision[:pattern]][:uses] += 1
      end

      save_performance_data
      decision_record
    end

    def record_outcome(decision_record, outcome, success_score)
      decision_record[:outcome] = outcome
      decision_record[:success_score] = success_score

      # Update pattern performance
      if decision_record[:decision][:pattern]
        pattern = decision_record[:decision][:pattern]
        @pattern_performance[pattern][:successes] += success_score
        @pattern_performance[pattern][:avg_score] = @pattern_performance[pattern][:successes].to_f / @pattern_performance[pattern][:uses]
      end

      # Extract lessons and update adaptation rules
      lessons = analyze_decision_outcome(decision_record)
      decision_record[:lessons_learned] = lessons

      apply_adaptation_rules(decision_record, lessons)
      save_performance_data
    end

    def get_adapted_decision_recommendation(current_context)
      # Find similar past contexts and their outcomes
      similar_decisions = find_similar_decisions(current_context)

      if similar_decisions.any?
        # Weight recommendations by success scores
        recommendations = similar_decisions.group_by { |d| d[:decision][:action] }
        best_action = recommendations.max_by do |action, decisions|
          decisions.sum { |d| d[:success_score] || 0 } / decisions.size
        end

        {
          recommended_action: best_action[0],
          confidence: calculate_adaptation_confidence(similar_decisions),
          based_on_decisions: similar_decisions.size,
          adaptation_reason: "learned_from_past_experience"
        }
      else
        nil
      end
    end

    def tune_pattern_weights
      # Adjust pattern scoring based on performance
      @pattern_performance.each do |pattern_id, stats|
        if stats[:uses] > 3 # Minimum sample size
          performance_multiplier = stats[:avg_score] > 0.7 ? 1.2 : 0.8
          adjust_pattern_weight(pattern_id, performance_multiplier)
        end
      end
    end

    def get_performance_report
      {
        total_decisions: @decision_history.size,
        success_rate: calculate_overall_success_rate,
        top_performing_patterns: @pattern_performance.sort_by { |_, stats| stats[:avg_score] }.reverse.first(3),
        adaptation_rules_applied: @adaptation_rules.size,
        recent_lessons: @decision_history.last(5).flat_map { |d| d[:lessons_learned] }
      }
    end

    private

    def find_similar_decisions(context)
      @decision_history.select do |decision_record|
        context_similarity(decision_record[:context], context) > 0.7
      end
    end

    def context_similarity(context1, context2)
      return 0 if context1.nil? || context2.nil?

      # Compare key settlement metrics
      metrics = [:oxygen_level, :water_level, :food_level, :debt_level]
      similarities = metrics.map do |metric|
        next 1.0 if context1[metric] == context2[metric]
        next 0.0 if context1[metric].nil? || context2[metric].nil?

        # Calculate similarity score (inverse of normalized difference)
        diff = (context1[metric] - context2[metric]).abs
        max_val = [context1[metric], context2[metric]].max
        1.0 - (diff.to_f / max_val)
      end

      similarities.sum / similarities.size
    end

    def calculate_adaptation_confidence(similar_decisions)
      return 0.0 if similar_decisions.empty?

      # Confidence based on sample size and consistency
      sample_size = similar_decisions.size
      scores = similar_decisions.map { |d| d[:success_score] || 0 }
      consistency = scores.max - scores.min # Simple consistency measure

      base_confidence = [sample_size / 10.0, 1.0].min
      consistency_penalty = consistency > 0.3 ? 0.2 : 0.0

      [base_confidence - consistency_penalty, 0.1].max
    end

    def analyze_decision_outcome(decision_record)
      lessons = []

      decision = decision_record[:decision]
      outcome = decision_record[:outcome]
      success_score = decision_record[:success_score]

      # Analyze based on decision type
      case decision[:action]
      when :emergency_procurement
        if success_score < 0.5
          lessons << "emergency_procurement_failed_consider_alternatives"
        end
      when :resource_procurement
        if success_score > 0.8
          lessons << "resource_procurement_successful_increase_buffer"
        end
      when :expansion
        if success_score < 0.6
          lessons << "expansion_pattern_#{decision[:pattern]}_underperformed"
        elsif success_score > 0.9
          lessons << "expansion_pattern_#{decision[:pattern]}_highly_effective"
        end
      end

      # Context-specific lessons
      context = decision_record[:context]
      if context[:debt_level].to_i > 50000 && decision[:action] == :expansion
        lessons << "high_debt_expansion_risky"
      end

      lessons
    end

    def apply_adaptation_rules(decision_record, lessons)
      lessons.each do |lesson|
        case lesson
        when /emergency_procurement_failed/
          @adaptation_rules[:prefer_alternative_procurement] = true
        when /resource_procurement_successful/
          @adaptation_rules[:increase_resource_buffers] = (@adaptation_rules[:increase_resource_buffers] || 0) + 1
        when /expansion_pattern_(.+)_underperformed/
          pattern_id = $1
          @adaptation_rules["reduce_#{pattern_id}_usage"] = true
        when /high_debt_expansion_risky/
          @adaptation_rules[:debt_aware_expansion] = true
        end
      end
    end

    def calculate_overall_success_rate
      return 0.0 if @decision_history.empty?

      successful_decisions = @decision_history.count { |d| (d[:success_score] || 0) > 0.7 }
      successful_decisions.to_f / @decision_history.size
    end

    def adjust_pattern_weight(pattern_id, multiplier)
      # This would modify the pattern scoring in the main patterns file
      # For now, we'll track it in performance data
      @pattern_performance[pattern_id][:weight_multiplier] = multiplier
    end

    def load_adaptation_rules
      rules_file = GalaxyGame::Paths::AI_ADAPTATION_RULES_PATH
      File.exist?(rules_file) ? JSON.parse(File.read(rules_file)) : {}
    end

    def load_existing_performance_data
      perf_file = GalaxyGame::Paths::AI_PERFORMANCE_PATH.join("performance_#{@settlement_id}.json")
      if File.exist?(perf_file)
        data = JSON.parse(File.read(perf_file))
        @decision_history = data['decision_history']&.map(&:deep_symbolize_keys) || []
        @pattern_performance = data['pattern_performance']&.deep_symbolize_keys || {}
      end
    end

    def save_performance_data
      perf_file = GalaxyGame::Paths::AI_PERFORMANCE_PATH.join("performance_#{@settlement_id}.json")
      FileUtils.mkdir_p(perf_file.dirname)

      data = {
        settlement_id: @settlement_id,
        decision_history: @decision_history.last(100), # Keep last 100 decisions
        pattern_performance: @pattern_performance,
        adaptation_rules: @adaptation_rules,
        last_updated: Time.current.iso8601
      }

      File.write(perf_file, JSON.pretty_generate(data))
    end
  end
end