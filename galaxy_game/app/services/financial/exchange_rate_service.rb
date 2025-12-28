module Financial
  class ExchangeRateService
  # Example: { ["USD", "GCC"] => 1.0, ["LOX", "USD"] => 2.5 }
  def initialize(rates = {})
    @rates = rates
  end

  # Convert an amount from one currency or item to another currency
  def convert(amount, from, to)
    return amount if from.to_s == to.to_s
    rate = get_rate(from, to)
    amount * rate
  end

  # Get the exchange rate from one currency/item to another currency
  def get_rate(from, to)
    key = [from.to_s, to.to_s]
    @rates[key] || 1.0 # Default to 1:1 if not found
  end

  # Set or update a rate (can be currency or item)
  def set_rate(from, to, rate)
    @rates[[from.to_s, to.to_s]] = rate
  end

  # Value an item in a given currency
  # Example: value_of("LOX", 1000, "USD") => 2500 if 1 LOX = 2.5 USD
  def value_of(item, quantity, target_currency)
    convert(quantity, item, target_currency)
  end

  # Get the base price of an item or blueprint in a given currency
  def base_price_for(entity_id, target_currency)
    # Try item lookup first
    item = Lookup::ItemLookupService.new.find_item(entity_id)
    if item && item.dig('game_properties', 'value')
      value = item['game_properties']['value'].to_f
      currency = item['game_properties']['currency'] || 'GCC'
      return convert(value, currency, target_currency)
    end

    # Try blueprint lookup
    blueprint = Lookup::BlueprintLookupService.new.find_blueprint(entity_id)
    if blueprint && blueprint.dig('cost_data', 'purchase_cost', 'amount')
      value = blueprint['cost_data']['purchase_cost']['amount'].to_f
      currency = blueprint['cost_data']['purchase_cost']['currency'] || 'GCC'
      return convert(value, currency, target_currency)
    end

    # Fallback: use Ollama or a default value
    default_value = 100.0
    convert(default_value, 'GCC', target_currency)
  end

  # Later, add market price lookup here
  def market_price_for(entity_id, target_currency)
    # TODO: Query market system for average price
    nil
  end

  # Unified price lookup: prefer market price, fallback to base price
  def price_for(entity_id, target_currency)
    market = market_price_for(entity_id, target_currency)
    return market if market
    base_price_for(entity_id, target_currency)
  end
end
end