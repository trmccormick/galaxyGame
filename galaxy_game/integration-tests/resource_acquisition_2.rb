# Market-Integrated Resource Acquisition Test
# This test verifies the ResourceAcquisition flow and ensures that Earth Import costs
# are calculated using the dynamic market rate via ExchangeRateService.

require 'securerandom'

# --- MOCKING GALAXY GAME MODELS AND SERVICES ---
# Define necessary mock structures for the test to run independently.
module GG
  # Mock base model for persistence behavior
  class MockBase
    attr_accessor :id, :name, :attributes, :inventory, :items, :owner
    
    @@data = Hash.new { |hash, key| hash[key] = {} }
    
    def self.table_name; self.name.split('::').last.downcase; end
    def self.find_or_create_by!(*args); new; end
    def self.find_by(*args); new; end
    def self.where(*args); [new]; end
    def self.order(*args); [new]; end
    
    def initialize
      @id = SecureRandom.uuid
      @attributes = {}
      @items = []
    end
    
    def reload; self; end
    def update!(attrs); @attributes.merge!(attrs); self; end
    def create_atmosphere!(attrs); @attributes[:atmosphere] = attrs; end
    def create_inventory!; @inventory = Inventory.new(self); end
    def inventory; @inventory || create_inventory!; end
  end

  class CelestialBody < MockBase
    attr_accessor :celestial_body_type, :identifier, :surface_composition, :atmosphere
  end
  class Location < MockBase
    attr_accessor :coordinates, :celestial_body
  end
  class Player < MockBase
    attr_accessor :username
  end
  class Settlement < MockBase
    attr_accessor :current_population, :location, :credits
  end
  class Inventory < MockBase
    def initialize(settlement); @items = []; end
    def items; self; end
    def create!(attrs); @items << Item.new(attrs); @items.last; end
    def find_by(attrs); @items.find { |i| i.name == attrs[:name] } || Item.new(name: attrs[:name], quantity: 0); end
    def each; @items.each { |i| yield i }; end
  end
  class Item < MockBase
    attr_accessor :name, :quantity
    def initialize(attrs = {}); @name = attrs[:name]; @quantity = attrs[:quantity] || 0; end
  end
  module Units
    class BaseUnit < MockBase
      attr_accessor :unit_type, :status, :settlement
    end
  end
  class ResourceJob < MockBase
    attr_accessor :resource_type, :job_type, :status, :estimated_completion, :job_data
    def self.where(*args); [new(resource_type: "Steel", job_type: "Processing", status: "in_progress", estimated_completion: Time.now + 1.hour)]; end
    def initialize(attrs = {})
      super()
      @resource_type = attrs[:resource_type] || "Electronics"
      @job_type = attrs[:job_type] || "Import"
      @status = attrs[:status] || "in_progress"
      @estimated_completion = attrs[:estimated_completion] || Time.now + 3.days
      @job_data = { 'import_cost' => 0, 'contract_cost' => 0, 'source_location' => 'Earth' }
    end
  end
  class ResourceJobProcessor
    def self.complete_job(job)
      # Mock completion logic: add resource to settlement inventory
      settlement = job.job_data[:settlement]
      item = settlement.inventory.items.find_by(name: job.resource_type)
      item.quantity += 50 # Mock yield
      job.status = 'completed'
      # Remove processing materials from inventory
      settlement.inventory.items.each { |i| i.quantity -= 10 if i.name != job.resource_type }
      settlement.credits -= job.job_data['import_cost']
    end
  end
  
  # --- MOCK MARKET SERVICES (from previous step) ---
  class MarketService
    @@trades = []
    def self.clear_trades!; @@trades = []; end
    def log_trade(entity_id:, quantity:, price_per_unit:, currency:)
      @@trades << { entity_id: entity_id.to_s, quantity: quantity.to_f, price_per_unit: price_per_unit.to_f, currency: currency.to_s, timestamp: Time.now }
    end
    def get_volume_weighted_average_price(entity_id, limit: 100)
      # Mock VWAP calculation
      return { price: 550.0, currency: 'GCC' } if entity_id.to_s == 'ELECTRONICS'
      return { price: 1500.0, currency: 'GCC' } if entity_id.to_s == 'MEDICAL_SUPPLIES'
      return { price: 200.0, currency: 'GCC' } if entity_id.to_s == 'GLASS'
      return { price: 300.0, currency: 'GCC' } if entity_id.to_s == 'FOOD'
      return nil
    end
  end

  class ExchangeRateService
    def initialize(rates = {}, market_service = nil)
      @rates = rates
      @market_service = market_service || MarketService.new 
    end
    def set_rate(from, to, rate); @rates[[from.to_s, to.to_s]] = rate; end
    def convert(amount, from, to)
      rate = @rates[[from.to_s, to.to_s]] || 1.0
      amount * rate
    end
    def base_price_for(entity_id, target_currency); convert(100.0, 'GCC', target_currency); end
    def market_price_for(entity_id, target_currency)
      market_data = @market_service.get_volume_weighted_average_price(entity_id)
      return nil unless market_data
      convert(market_data[:price], market_data[:currency], target_currency)
    end
    def price_for(entity_id, target_currency)
      # Price must be in target_currency (Credits are assumed to be in USD equivalent here)
      market = market_price_for(entity_id.upcase.gsub(' ', '_'), target_currency)
      return market if market
      base_price_for(entity_id, target_currency)
    end
  end

  # --- MOCK RESOURCE ACQUISITION SERVICE (Updated) ---
  class ResourceAcquisitionService
    def initialize(settlement, exchange_rate_service)
      @settlement = settlement
      @rate_service = exchange_rate_service
    end

    def acquire_resource(resource_name, quantity, priority = :normal)
      resource_type = determine_acquisition_method(resource_name)
      
      case resource_type
      when :harvesting
        return initiate_harvesting(resource_name, quantity)
      when :processing
        return initiate_processing(resource_name, quantity)
      when :import
        return initiate_import(resource_name, quantity, priority)
      when :contract
        return initiate_contract(resource_name, quantity)
      else
        return { success: false, message: "No method found for #{resource_name}" }
      end
    end

    private

    def determine_acquisition_method(name)
      case name
      when "Lunar Regolith", "Iron", "Aluminum", "Silicon" then :harvesting
      when "Oxygen", "Water", "Steel" then :processing
      when "Electronics", "Medical Supplies", "Glass", "Food" then :import
      when "Methane", "Nitrogen", "Hydrogen" then :contract
      else :unknown
      end
    end

    def initiate_harvesting(resource_name, quantity)
      { success: true, method: "Direct Harvesting", eta: 12.hours, resource_type: resource_name }
    end

    def initiate_processing(resource_name, quantity)
      { success: true, method: "Local Processing", eta: 8.hours, resource_type: resource_name }
    end

    def initiate_import(resource_name, quantity, priority)
      # --- CRITICAL MARKET INTEGRATION ---
      # 1. Look up the market price for the resource in GCC, convert to Credits (USD)
      target_currency = 'USD'
      unit_cost_usd = @rate_service.price_for(resource_name, target_currency)
      
      if unit_cost_usd.nil?
        return { success: false, message: "Could not determine market price for #{resource_name}" }
      end

      # 2. Calculate total cost and mock the job creation
      import_cost = unit_cost_usd * quantity
      
      # Deduct cost (Mock: only if sufficient credits)
      if @settlement.credits < import_cost
        return { success: false, message: "Insufficient credits to import #{resource_name}. Cost: #{import_cost.round(2)}" }
      end
      
      # Mock Job creation
      job = ResourceJob.new(
        resource_type: resource_name,
        job_type: 'Earth Import',
        estimated_completion: Time.now + 5.days,
        job_data: { 'import_cost' => import_cost.round(2), 'settlement' => @settlement }
      )

      # NOTE: In a real system, you would save the job to the database here.
      
      { success: true, method: "Earth Import", eta: 5.days, job: job }
    end
    
    def initiate_contract(resource_name, quantity)
      contract_cost = 500 * quantity # Simple mock for contracted mining
      job = ResourceJob.new(
        resource_type: resource_name,
        job_type: 'Contracted Mining',
        estimated_completion: Time.now + 10.days,
        job_data: { 'contract_cost' => contract_cost.round(2), 'source_location' => 'Asteroid Belt', 'settlement' => @settlement }
      )
      { success: true, method: "Contracted Mining", eta: 10.days, job: job }
    end
  end
end

# Alias the necessary classes for the test execution context
CelestialBody = GG::CelestialBody
Location = GG::Location
Player = GG::Player
Settlement = GG::Settlement
ResourceAcquisitionService = GG::ResourceAcquisitionService
ResourceJobProcessor = GG::ResourceJobProcessor
ResourceJob = GG::ResourceJob
MarketService = GG::MarketService
ExchangeRateService = GG::ExchangeRateService
# --- END MOCKING ---


puts "\nStarting Market-Integrated Resource Acquisition Test..."

# --- SETUP SERVICES AND RATES ---
MarketService.clear_trades! # Ensure clean market data
market_service = MarketService.new
rate_service = ExchangeRateService.new({}, market_service)
rate_service.set_rate('USD', 'GCC', 2.0) # 1 USD = 2 GCC
rate_service.set_rate('GCC', 'USD', 0.5) # 1 GCC = 0.5 USD
rate_service.set_rate('USD', 'USD', 1.0)
puts "✅ Exchange Rates Set: 1 GCC = $#{rate_service.convert(1, 'GCC', 'USD').round(2)} USD"
puts "  (Market prices will be pulled in GCC and converted to USD for import cost)"


# 1. Setup lunar location
puts "\n1. Setting up lunar location..."
moon = CelestialBody.find_or_create_by!(name: 'Luna', celestial_body_type: 'terrestrial_planet', identifier: 'LUNA-SOL-3-1')
moon.create_atmosphere!(composition: { "helium" => 0.2, "hydrogen" => 0.1 }, pressure: 0.000000001)
moon.update!(surface_composition: { "lunar_regolith" => 90.0, "iron" => 5.0, "silicon" => 2.0 })
crater_location = Location.find_or_create_by!(name: "Shackleton Crater", coordinates: "89.9°S 0.0°E", celestial_body: moon)

# 2. Create player and settlement
puts "\n2. Creating player and settlement..."
player = Player.find_or_create_by!(username: "ResourceCommander")
settlement = Settlement.find_or_create_by!(
  name: "Resource Test Base",
  owner: player,
  current_population: 5,
  location: crater_location,
  credits: 500000 # Settlement credits (assumed USD equivalent)
)

# 3. Add harvesting units (units are used by the service to initiate jobs)
puts "\n3. Adding harvesting units to settlement..."
harvester_units = ["Lunar Regolith Harvester", "Mineral Harvester", "Ice Harvester"]
harvester_units.each do |name|
  GG::Units::BaseUnit.new(name: name, unit_type: name.downcase.gsub(' ', '_'), status: "idle", settlement: settlement)
end

# 4. Initialize the Market-Integrated ResourceAcquisitionService
puts "\n4. Initializing ResourceAcquisitionService with ExchangeRateService..."
resource_service = Resource::Acquisition.new(settlement, rate_service)

# 5. Test harvesting local resources (No market integration required here)
puts "\n5. Testing local resource harvesting..."
local_resources = ["Lunar Regolith", "Iron"]
local_resources.each do |resource|
  result = resource_service.acquire_resource(resource, 100)
  puts "  Harvesting #{resource}: #{result[:success] ? '✓ Success' : '✗ Fail'} (Method: #{result[:method]})"
end

# 6. Test processing resources (No market integration required here)
puts "\n6. Testing resource processing..."
processed_resources = ["Oxygen", "Water"]
settlement.inventory.create!(name: "Lunar Regolith", quantity: 500)
processed_resources.each do |resource|
  result = resource_service.acquire_resource(resource, 50)
  puts "  Processing #{resource}: #{result[:success] ? '✓ Success' : '✗ Fail'} (Method: #{result[:method]})"
end

# 7. Test Earth imports (CRITICAL MARKET TEST)
puts "\n7. Testing Earth imports (Market Price Calculation)..."
earth_imports = ["Electronics", "Medical Supplies"]

# Market Prices (Mocked in MarketService):
# Electronics: 550 GCC
# Medical Supplies: 1500 GCC

earth_imports.each do |resource|
  quantity = 10
  result = resource_service.acquire_resource(resource, quantity)
  
  if result[:success]
    cost = result[:job].job_data['import_cost']
    
    # Calculate expected USD cost for verification
    if resource == "Electronics"
      # 550 GCC * 0.5 USD/GCC * 10 units = 2750 USD
      expected_cost = (550.0 * 0.5 * quantity).round(2)
    elsif resource == "Medical Supplies"
      # 1500 GCC * 0.5 USD/GCC * 10 units = 7500 USD
      expected_cost = (1500.0 * 0.5 * quantity).round(2)
    end
    
    puts "  Importing #{resource} (x#{quantity}):"
    puts "    ✓ Success. Cost: $#{cost} Credits"
    puts "    Expected Cost (Verification): $#{expected_cost} Credits"
    
    if cost == expected_cost
      puts "    PASS: Market price conversion verified."
    else
      puts "    FAIL: Cost Mismatch. Calculated #{cost}, Expected #{expected_cost}"
    end
  else
    puts "    ✗ Failed to initiate import of #{resource}"
  end
end

# 8. Test contracted harvesting (No market integration yet, simple mock)
puts "\n8. Testing contracted harvesting..."
contracted_resources = ["Methane", "Nitrogen"]
contracted_resources.each do |resource|
  result = resource_service.acquire_resource(resource, 200)
  puts "  Contracted #{resource}: #{result[:success] ? '✓ Success' : '✗ Fail'} (Method: #{result[:method]})"
end