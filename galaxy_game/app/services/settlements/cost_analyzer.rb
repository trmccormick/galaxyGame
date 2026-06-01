# frozen_string_literal: true

module Settlements
  class CostAnalyzer
    class ResourceNotFoundError < StandardError; end

    # Compare local production cost vs. import price for a resource
    # Returns a hash with cost details and recommendation
    def self.compare_costs(resource_name, settlement)
      local_cost = local_production_cost(resource_name, settlement)
      import_cost = current_import_price(resource_name, settlement)
      confidence = import_cost.nil? ? :low : :high
      if local_cost.nil?
        raise ResourceNotFoundError, "No blueprint or cost data for resource: #{resource_name}"
      end
      if import_cost.nil?
        recommendation = :produce_locally
        local_cheaper = true
        cost_delta = 0.0
      else
        local_cheaper = local_cost < import_cost
        recommendation = local_cheaper ? :produce_locally : :import
        cost_delta = (import_cost - local_cost).abs
      end
      {
        resource: resource_name,
        local_cost: local_cost,
        import_cost: import_cost,
        local_cheaper: local_cheaper,
        cost_delta: cost_delta,
        recommendation: recommendation,
        confidence: confidence
      }
    rescue ResourceNotFoundError => e
      {
        resource: resource_name,
        local_cost: nil,
        import_cost: nil,
        local_cheaper: nil,
        cost_delta: nil,
        recommendation: :error,
        confidence: :low,
        error: e.message
      }
    end

    # Calculate cost to produce resource locally (GCC per unit)
    def self.local_production_cost(resource_name, settlement)
      lookup = Lookup::BlueprintLookupService.new
      blueprint = lookup.find_blueprint(resource_name)
      return nil unless blueprint && blueprint['required_materials']
      total = 0.0
      blueprint['required_materials'].each do |mat, req|
        base_cost = base_material_cost(mat)
        return nil if base_cost.nil?
        total += base_cost * req.to_f
      end
      total
    end

    # Fetch base cost for a material from constants or config
    def self.base_material_cost(material_name)
      # TODO: Replace with actual lookup from constants or config
      # Example: GameConstants::BASE_MATERIAL_COSTS[material_name]
      # For now, return a stub value for testability
      {
        'Iron' => 10.0,
        'Coal' => 5.0,
        'Oxygen' => 2.0,
        'Steel' => 0.0 # Should not be used directly
      }[material_name] || 1.0
    end

    # Fetch current import price from the settlement's marketplace
    def self.current_import_price(resource_name, settlement)
      return nil unless settlement&.marketplace
      cond = settlement.marketplace.current_market_condition(resource_name)
      return nil unless cond && cond.respond_to?(:price)
      cond.price
    end
  end
end
