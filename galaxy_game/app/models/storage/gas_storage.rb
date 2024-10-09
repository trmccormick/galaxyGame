# app/models/storage/gas_storage.rb
module Storage
  class GasStorage < BaseStorage
    attr_accessor :gas_type, :pressure

    def initialize(capacity, gas_type, pressure = 1.0) # Default pressure at 1.0 atm
      super(capacity, 'Gas')                        # Specify type as 'Gas'
      @gas_type = gas_type                          # Store the type of gas
      @pressure = pressure                          # Store the pressure
    end

    def transfer_to(other_storage, quantity)
      return "Not enough capacity in destination." unless other_storage.can_add?(quantity)

      if @current_stock >= quantity
        remove_item(gas_type, quantity)             # Remove from current storage
        other_storage.add_item(gas_type, quantity)  # Add to other storage
        return "#{quantity} units of #{gas_type} transferred."
      else
        return "Not enough #{gas_type} available to transfer."
      end
    end

    def calculate_volume(temperature)
      # Example: Ideal Gas Law: PV = nRT, where V = nRT/P
      n = @current_stock / molar_mass(gas_type)   # Calculate number of moles
      r = 0.0821                                    # Ideal gas constant (L·atm/(K·mol))
      return (n * r * temperature) / pressure      # Calculate volume
    end

    private

    def molar_mass(gas_type)
      # A simple method to return molar mass based on gas type (in g/mol)
      case gas_type
      when 'Oxygen'
        32.0
      when 'Hydrogen'
        2.0
      else
        0.0 # Default case for unknown gases
      end
    end
  end
end

  