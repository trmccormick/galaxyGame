module Logistics
  class Provider < ApplicationRecord
    self.table_name = 'logistics_providers'
    belongs_to :organization, class_name: 'Organizations::BaseOrganization', optional: true

    validates :name, presence: true, uniqueness: true
    validates :identifier, presence: true, uniqueness: true
    validates :reliability_rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
    validates :base_fee_per_kg, numericality: { greater_than: 0 }
    validates :speed_multiplier, numericality: { greater_than: 0 }

    # Store capabilities, cost_modifiers, time_modifiers as JSON
    serialize :capabilities, JSON
    serialize :cost_modifiers, JSON
    serialize :time_modifiers, JSON

    # Calculate shipping cost for a given route and cargo
    def calculate_cost(from_settlement, to_settlement, material, quantity, transport_method)
      base_cost = base_fee_per_kg * quantity

      # Apply bulk discounts
      if cost_modifiers && cost_modifiers['bulk_discount_thresholds']
        cost_modifiers['bulk_discount_thresholds'].each do |threshold|
          if quantity >= threshold['quantity']
            base_cost *= threshold['multiplier']
          end
        end
      end

      # Specialty discount for orbital transfers
      if transport_method.to_sym == :orbital_transfer && cost_modifiers && cost_modifiers['orbital_transfer_discount']
        base_cost *= cost_modifiers['orbital_transfer_discount']
      end

      # Distance multiplier (simplified - could be more complex)
      distance_multiplier = calculate_distance_multiplier(from_settlement, to_settlement)

      # Material type adjustments
      material_multiplier = material_risk_multiplier(material)

      # Transport method efficiency
      efficiency_multiplier = transport_efficiency(transport_method)

      (base_cost * distance_multiplier * material_multiplier * efficiency_multiplier).round(2)
    end

    # Estimate delivery time in hours
    def estimate_delivery_time(from_settlement, to_settlement, transport_method)
      base_time = case transport_method.to_sym
                  when :orbital_transfer then 24  # 1 day
                  when :surface_conveyance then 72  # 3 days
                  when :drone_delivery then 12  # 12 hours
                  else 48
                  end

      # Apply time modifiers
      if transport_method.to_sym == :orbital_transfer && time_modifiers['orbital_transfer_speedup']
        base_time = (base_time * time_modifiers['orbital_transfer_speedup']).round
      end

      # Distance adjustment
      distance_factor = calculate_distance_factor(from_settlement, to_settlement)

      (base_time * distance_factor / speed_multiplier).round
    end

    # Check if provider can handle this route
    def can_handle_route?(from_settlement, to_settlement, transport_method)
      capabilities[transport_method.to_s] || false
    end

    private

    def calculate_distance_multiplier(from_settlement, to_settlement)
      # Simplified distance calculation
      # In a real implementation, this would use actual celestial coordinates
      if from_settlement.celestial_body == to_settlement.celestial_body
        1.0  # Same body - surface transport
      else
        2.0  # Different bodies - orbital transfer required
      end
    end

    def calculate_distance_factor(from_settlement, to_settlement)
      if from_settlement.celestial_body == to_settlement.celestial_body
        1.0
      else
        1.5
      end
    end

    def material_risk_multiplier(material)
      # Higher risk materials cost more to transport
      case material.downcase
      when 'hydrogen', 'methane', 'oxygen' then 1.5  # Hazardous gases
      when 'water', 'ammonia' then 1.2  # Corrosive liquids
      else 1.0  # Standard materials
      end
    end

    def transport_efficiency(transport_method)
      case transport_method.to_sym
      when :orbital_transfer then 1.0
      when :surface_conveyance then 0.8
      when :drone_delivery then 1.2
      else 1.0
      end
    end
  end
end