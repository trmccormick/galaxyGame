# frozen_string_literal: true

# The MarketListingService handles the strategic pricing for manufactured units.
# It determines the optimal selling price for the LDC (Local Development Corporation)
# by calculating an undercut price relative to the Earth Corporation's price,
# while always ensuring the price stays above the calculated Cost of Goods Sold (COGS).
class MarketListingService
  # The fixed strategic margin the LDC aims to undercut the Earth Corp price by.
  # This is the AI's core strategy for gaining market dominance.
  UNDERCUT_MARGIN = 0.05 # 5% undercut

  # The minimum percentage profit margin the LDC will ever accept relative to its COGS.
  # This acts as a safety floor to prevent selling at a loss.
  MINIMUM_COGS_MARGIN = 0.01 # 1% margin above COGS

  attr_reader :unit_blueprint, :cogs_floor

  # @param unit_blueprint [Hash] The blueprint containing the Earth purchase price.
  # @param cogs_floor [Float] The calculated COGS (either EAP-COGS or LAP-COGS).
  def initialize(unit_blueprint, cogs_floor)
    @unit_blueprint = unit_blueprint
    @cogs_floor = cogs_floor
  end

  # Determines the final listing price for the unit.
  #
  # The strategy is:
  # 1. Calculate the target price by undercutting the Earth Price by the defined margin (5%).
  # 2. Calculate the absolute minimum acceptable price (COGS + 1% margin).
  # 3. The final listing price is the HIGHER of these two:
  #    - Target Undercut Price (to beat the competition)
  #    - Minimum Acceptable Price (to avoid selling at a loss)
  #
  # @return [Float] The final determined selling price in GCC.
  def determine_listing_price
    # 1. Get the price set by the Earth Corporation (our competitor)
    earth_price = unit_blueprint.dig('cost_data', 'purchase_cost', 'amount')
    return @cogs_floor if earth_price.nil? || earth_price == 0

    # 2. Calculate the target undercut price
    # Example: If Earth Price is 8500, Undercut Price is 8500 * (1 - 0.05) = 8075
    target_undercut_price = earth_price * (1 - UNDERCUT_MARGIN)

    # 3. Calculate the absolute minimum price (COGS floor + safety margin)
    # Example: If COGS is 7178.95, Minimum Price is 7178.95 * 1.01 = 7250.74
    minimum_acceptable_price = @cogs_floor * (1 + MINIMUM_COGS_MARGIN)

    # 4. Final price selection: We must always cover our costs, even if it means 
    #    not fully achieving the target undercut. We take the higher of the two.
    final_price = [target_undercut_price, minimum_acceptable_price].max

    final_price.round(2)
  end
end