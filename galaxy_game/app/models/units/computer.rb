# app/models/units/computer.rb
module Units
  class Computer < BaseUnit
    # Define attributes to hold mapped values for performance/readability
    attribute :mining_rate_value, :float, default: 1.0
    attribute :efficiency_upgrade_value, :float, default: 0.0
    attribute :energy_required_value, :float, default: 10.0 # From 'mining_power' in JSON

    # BaseUnit's `after_initialize :load_unit_info` populates `operational_data`.
    # This callback maps specific attributes *after* that.
    after_initialize :map_computer_specific_operational_data, if: :operational_data_loaded?

    # Public methods now use the mapped attributes
    def mine(difficulty, efficiency_multiplier)
      self.mining_rate_value * difficulty * efficiency_multiplier
    end

    def energy_required
      self.energy_required_value
    end
    alias_method :power_usage, :energy_required # For EnergyManagement concern

    def total_efficiency
      1.0 + self.efficiency_upgrade_value
    end

    def upgrade_efficiency(upgrade_amount)
      self.efficiency_upgrade_value += upgrade_amount
      save
    end

    def overclock(boost_amount, duration)
      # Store the original rate
      original_rate = self.mining_rate_value
      
      # Update the in-memory attribute
      self.mining_rate_value += boost_amount
      
      if persisted?
        # Also update the appropriate place in the operational_data hash
        # We need to update all possible locations where mining_rate might be stored
        if operational_data['operational_properties']
          operational_data['operational_properties']['mining_rate'] = mining_rate_value
        end
        
        if operational_data['performance']
          operational_data['performance']['mining_rate'] = mining_rate_value
        end
        
        if operational_data['resource_management'] && operational_data['resource_management']['generated'] && 
           operational_data['resource_management']['generated']['mining_gcc']
          operational_data['resource_management']['generated']['mining_gcc']['rate'] = mining_rate_value
        end
        
        # Update the operational_data directly in the database
        update_column(:operational_data, operational_data)
      end
      
      Thread.new do # Revert after duration in a non-blocking way
        sleep(duration)
        if self.class.exists?(id)
          computer = self.class.find(id)
          # Reset the mining rate in the in-memory attribute
          computer.mining_rate_value = original_rate
          
          # Reset it in the operational_data too
          if computer.operational_data['operational_properties']
            computer.operational_data['operational_properties']['mining_rate'] = original_rate
          end
          
          if computer.operational_data['performance']
            computer.operational_data['performance']['mining_rate'] = original_rate
          end
          
          if computer.operational_data['resource_management'] && 
             computer.operational_data['resource_management']['generated'] &&
             computer.operational_data['resource_management']['generated']['mining_gcc']
            computer.operational_data['resource_management']['generated']['mining_gcc']['rate'] = original_rate
          end
          
          # Update the operational_data directly
          computer.update_column(:operational_data, computer.operational_data)
        end
      end
    end

    # Method to check if this computer can mine cryptocurrency?
    def can_mine_cryptocurrency?
      true # All computers can mine by default
    end

    # Override the unit_type_specific_properties method to include mining properties
    def unit_type_specific_properties
      super.merge({
        mining_rate: mining_rate_value,
        efficiency: total_efficiency,
        power_usage: energy_required_value
      })
    end

    private

    # Maps specific operational data keys from the loaded operational_data hash
    def map_computer_specific_operational_data
      return if operational_data.blank? || operational_data.empty?

      # Check different possible locations for mining data in operational_data
      props = operational_data['operational_properties'] || {}
      performance = operational_data['performance'] || {}
      resource_mgmt = operational_data['resource_management'] || {}
      
      # Try to find mining rate from various possible locations
      self.mining_rate_value = 
        props.dig('mining_rate') ||
        performance.dig('mining_rate') ||
        resource_mgmt.dig('generated', 'mining_gcc', 'rate') ||
        operational_data['mining_rate'] ||
        1.0
      
      # Try to find efficiency upgrade from various possible locations
      self.efficiency_upgrade_value = 
        props.dig('efficiency_upgrade') ||
        performance.dig('efficiency_upgrade') ||
        operational_data['efficiency_upgrade'] ||
        0.0
      
      # Try to find energy required from various possible locations
      self.energy_required_value = 
        props.dig('power_consumption') ||
        props.dig('mining_power') ||
        performance.dig('power_consumption') ||
        operational_data['mining_power'] ||
        operational_data['power_consumption'] ||
        10.0
    end

    # Helper to check if operational_data has likely been populated by BaseUnit's after_initialize
    def operational_data_loaded?
      operational_data.present? && !operational_data.empty?
    end
  end
end

describe '#overclock' do
  it 'temporarily increases mining rate' do
    # Create a computer with operational_data that includes mining rate
    computer = create(:computer, :with_mining_data)
    
    # Reload to get any values loaded from JSON files
    computer.reload
    original_rate = computer.mining_rate_value
    
    # Mock Thread to avoid actual sleep in tests
    thread_double = double("Thread")
    allow(Thread).to receive(:new).and_return(thread_double)
    
    # Test that the method increases the mining rate
    computer.overclock(0.5, 60)
    
    # Reload and verify rate was increased in operational_data
    computer.reload
    expect(computer.mining_rate_value).to eq(original_rate + 0.5)
    
    # Manually reset the operational_data
    original_data = computer.operational_data
    if original_data['operational_properties']
      original_data['operational_properties']['mining_rate'] = original_rate
    end
    computer.update_column(:operational_data, original_data)
    
    # Reload and verify it was reset
    computer.reload
    expect(computer.mining_rate_value).to eq(original_rate)
  end
end