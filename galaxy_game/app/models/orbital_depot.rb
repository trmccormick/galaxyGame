# TEMPORARY PORO MODEL FOR TESTING
# 
# This is a Plain Old Ruby Object used for rake task testing only.
# It provides simple in-memory gas storage without database persistence.
#
# TODO: Replace with Settlement::OrbitalDepot (app/models/settlement/orbital_depot.rb)
#       See ORBITAL_DEPOT_MIGRATION_PLAN.md for migration steps
#
# Production model features:
# - Database persistence via Inventory system
# - Settlement features (location, life support, power, etc.)
# - Metadata tracking for gas batches (source, purity, import year, etc.)
# - Integration with game's resource management system
#
# Represents an orbital depot/station inventory for gas storage
# Used for managing imported gases (H2, etc.) that shouldn't be dumped into planetary atmospheres
class OrbitalDepot
  attr_accessor :gases, :celestial_body_id, :name

  def initialize(celestial_body_id: nil, name: "Orbital Depot")
    @gases = Hash.new(0.0) # e.g., { 'H2' => 0.0, 'O2' => 0.0, 'N2' => 0.0 }
    @celestial_body_id = celestial_body_id
    @name = name
  end

  # Add gas to depot inventory
  def add_gas(gas_name, amount)
    raise ArgumentError, "Amount must be positive" if amount < 0
    @gases[gas_name] += amount.to_f
  end

  # Remove gas from depot inventory (returns actual amount removed, capped by available)
  def remove_gas(gas_name, amount)
    raise ArgumentError, "Amount must be positive" if amount < 0
    amt = [amount.to_f, @gases[gas_name]].min
    @gases[gas_name] -= amt
    amt
  end

  # Get current gas inventory
  def get_gas(gas_name)
    @gases[gas_name] || 0.0
  end

  # Check if depot has at least the requested amount
  def has_gas?(gas_name, amount)
    get_gas(gas_name) >= amount.to_f
  end

  # Get total mass of all gases
  def total_mass
    @gases.values.sum
  end

  # Get inventory summary
  def summary
    {
      name: @name,
      celestial_body_id: @celestial_body_id,
      total_mass: total_mass,
      gases: @gases.dup
    }
  end

  def to_s
    "#{@name} (#{@gases.keys.count} gas types, #{total_mass.round(2)} kg total)"
  end
end
