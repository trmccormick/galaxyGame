module Logistics
  class ShippingCalculator
    LAUNCH_COSTS = {
      'earth_to_leo' => 2700,  # GCC per kg
      'leo_to_moon' => 4050,   # 1.5x LEO cost
      'earth_to_moon' => 6750  # 2.5x LEO cost
    }

    def calculate_shipping(item_id:, quantity:, from:, to:)
      item = Lookup::ItemLookupService.new.find_item(item_id)
      return nil unless item

      total_weight = item['weight'] * quantity
      total_volume = item['volume'] * quantity
      base_cost = item['base_price'] * quantity
      
      route_cost = LAUNCH_COSTS["#{from}_to_#{to}"] || 0
      shipping_cost = total_weight * route_cost

      {
        base_cost: base_cost,
        shipping_cost: shipping_cost,
        total_cost: base_cost + shipping_cost,
        weight: total_weight,
        volume: total_volume,
        from: from,
        to: to
      }
    end
  end
end