# frozen_string_literal: true

module Portal
  class TransitValidation
    PORTAL_MAX_MASS = 100_000 # Example value, adjust as needed (kg)

    ResonanceOverloadError = Class.new(StandardError)

    # Validates whether a ship can transit the portal
    # @param ship [Ship] the ship attempting transit
    # @raise [ResonanceOverloadError] if mass exceeds limit
    def self.validate!(ship)
      if ship.mass > PORTAL_MAX_MASS
        raise ResonanceOverloadError, 'Resonance Overload: Ship mass exceeds portal limit.'
      end
      true
    end
  end
end
