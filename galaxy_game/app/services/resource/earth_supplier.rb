class Resource::EarthSupplier
  def self.calculate_total_cost(item_id, quantity, destination = 'luna')
    item = Lookup::ItemLookupService.new.find_item(item_id)
    return nil unless item
    
    # Base cost is FIXED (same everywhere)
    base_cost = item['value']['amount'] * quantity
    
    # Shipping cost varies by physics
    shipping_calc = Logistics::ShippingCalculator.new
    shipping_result = shipping_calc.calculate_shipping(
      item_id: item_id,
      quantity: quantity,
      from: 'earth',
      to: destination
    )
    
    {
      item_base_cost: base_cost,
      shipping_cost: shipping_result[:shipping_cost],
      total_cost: base_cost + shipping_result[:shipping_cost],
      weight: shipping_result[:weight],
      volume: shipping_result[:volume],
      cost_breakdown: {
        item_value: base_cost,
        transport: shipping_result[:shipping_cost],
        total: base_cost + shipping_result[:shipping_cost]
      }
    }
  end
  
  def self.find_cheapest_source(item_id, quantity, destination)
    # Compare costs from different sources
    sources = ['earth', 'luna', 'mars', 'asteroids']
    options = []
    
    sources.each do |source|
      next if source == destination
      
      # Check if item is available at source
      if item_available_at_source?(item_id, source)
        route_calc = Logistics::RouteCostCalculator.new
        cost = route_calc.calculate_route_cost(
          from: source,
          to: destination,
          distance: get_distance(source, destination),
          mass: get_item_weight(item_id) * quantity
        )
        
        item_base_cost = get_item_base_cost(item_id) * quantity
        
        options << {
          source: source,
          base_cost: item_base_cost,
          shipping_cost: cost,
          total_cost: item_base_cost + cost,
          delivery_time: calculate_delivery_time(source, destination)
        }
      end
    end
    
    # Return cheapest option
    options.min_by { |opt| opt[:total_cost] }
  end
end