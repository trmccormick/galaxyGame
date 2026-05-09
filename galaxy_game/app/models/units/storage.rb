# app/models/units/storage.rb
module Units
  class Storage < BaseUnit
    # === STORAGE UNIT EXTENSION PLAN ===

    # This class will eventually handle per-tank, per-gas, and per-owner logic.
    # The following methods are stubs or placeholders for future refactor.

    # Returns true if this tank can accept the given gas type (single-gas or mixed-gas logic)
    # TODO: Move/override from BaseUnit if needed
    def can_accept_gas?(gas_type)
      # Example logic:
      # return true if operational_data['storage']['allow_mixed_gases']
      # stored = operational_data['storage']['stored_material']
      # stored.nil? || stored == gas_type
      # (Stub)
      raise NotImplementedError, "Implement gas acceptance logic for storage units."
    end

    # Adds gas to this tank, updating operational_data and enforcing rules
    # TODO: Move/override from BaseUnit if needed
    def add_gas(gas_type, amount)
      # Example logic:
      # if can_accept_gas?(gas_type)
      #   ... update operational_data ...
      # end
      # (Stub)
      raise NotImplementedError, "Implement add_gas logic for storage units."
    end

    # Returns a hash of all gases and their amounts if mixed, or a single gas if not
    # TODO: Move/override from BaseUnit if needed
    def stored_gases
      # Example logic:
      # if operational_data['storage']['allow_mixed_gases']
      #   operational_data['storage']['stored_materials']
      # else
      #   { operational_data['storage']['stored_material'] => operational_data['storage']['current_level'] }
      # end
      # (Stub)
      raise NotImplementedError, "Implement stored_gases reporting for storage units."
    end

    # Returns true if the tank is empty
    # TODO: Move/override from BaseUnit if needed
    def empty?
      # Example logic:
      # operational_data['storage']['current_level'].to_f <= 0
      # (Stub)
      raise NotImplementedError, "Implement empty? check for storage units."
    end

    # Returns the current fill level (kg, L, etc.)
    # TODO: Move/override from BaseUnit if needed
    def current_level
      # Example logic:
      # operational_data['storage']['current_level']
      # (Stub)
      raise NotImplementedError, "Implement current_level for storage units."
    end

    # Returns the tank's total capacity
    # TODO: Move/override from BaseUnit if needed
    def capacity
      # Example logic:
      # operational_data['storage']['capacity']
      # (Stub)
      raise NotImplementedError, "Implement capacity for storage units."
    end

    # === END OF EXTENSION PLAN ===
  end
end
