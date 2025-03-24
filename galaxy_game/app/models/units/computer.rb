module Units
  class Computer < BaseUnit
    # Inherits owner, attachable, location, inventory, etc. from BaseUnit

    # Add attributes for mining rate and efficiency upgrades
    attribute :mining_rate, :float, default: 1.0 # Base mining rate
    attribute :efficiency_upgrade, :float, default: 0.0 # Upgrade bonus

    def mine(difficulty, efficiency_multiplier)
      # Calculate GCC generated based on mining rate, difficulty, and efficiency
      self.mining_rate * difficulty * efficiency_multiplier
    end

    def mining_power
      # Example: Base mining power, potentially influenced by upgrades
      operational_data['mining_power'] || 10 # Base power consumption from operational data
    end

    def total_efficiency
      # Calculates the total efficiency of the computer.
      1.0 + self.efficiency_upgrade
    end

    # Example: Method to upgrade mining efficiency (can be called by players)
    def upgrade_efficiency(upgrade_amount)
      self.efficiency_upgrade += upgrade_amount
      save
    end

    # Example: Method to overclock the computer for a temporary boost
    def overclock(boost_amount, duration)
      original_rate = self.mining_rate
      self.mining_rate += boost_amount
      save

      # Revert the rate after the duration
      Thread.new do
        sleep(duration)
        self.mining_rate = original_rate
        save
      end
    end

    private

    def load_unit_blueprint
      return if unit_type.blank?

      # Using the UnitBlueprintService
      blueprint = UnitBlueprintService.find_blueprint(unit_type)
      self.operational_data = blueprint if blueprint

      # Set the attributes from the operational data.
      self.mining_rate = operational_data['mining_rate'] if operational_data['mining_rate']
      self.efficiency_upgrade = operational_data['efficiency_upgrade'] if operational_data['efficiency_upgrade']

      save! if persisted?
    end
  end
end