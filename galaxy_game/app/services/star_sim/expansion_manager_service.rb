module StarSim
  class ExpansionManagerService
    def initialize(target_world:, debug_mode: false)
      @target_world = target_world
      @debug_mode = debug_mode
    end

    def execute_orbital_first_doctrine
      puts "[ExpansionManager] Executing Orbital-First Doctrine for #{@target_world.name}" if @debug_mode

      # DEPLOYMENT: Deploy a 'Seed Cycler' containing 'Precursor Items'
      deploy_seed_cycler

      # MOON LOGIC: Determine settlement type based on moon characteristics
      determine_settlement_type

      # MARKET BOOTSTRAP: Open order book for construction materials
      bootstrap_market_orders

      puts "[ExpansionManager] Orbital-First Doctrine complete for #{@target_world.name}" if @debug_mode
    end

    private

    def deploy_seed_cycler
      puts "[ExpansionManager] Deploying Seed Cycler with precursor items..." if @debug_mode

      # Create a seed cycler settlement/unit that contains refineries, fabricators, etc.
      # This would deploy orbital infrastructure first
      @seed_cycler = Settlement::OrbitalDepot.create!(
        name: "#{@target_world.name} Seed Cycler",
        location: @target_world.location,
        operational_data: {
          'precursor_items' => ['orbital_refinery', 'fabricator_module', 'power_generator'],
          'deployment_status' => 'active'
        }
      )

      puts "[ExpansionManager] Seed Cycler deployed: #{@seed_cycler.name}" if @debug_mode
    end

    def determine_settlement_type
      if @target_world.is_a?(CelestialBodies::Moon)
        if large_moon?(@target_world)
          puts "[ExpansionManager] Large moon detected - building surface settlement" if @debug_mode
          build_surface_settlement
        else
          puts "[ExpansionManager] Small moon detected - triggering moon conversion to station/depot" if @debug_mode
          convert_to_station_depot
        end
      else
        puts "[ExpansionManager] Planet detected - building orbital infrastructure" if @debug_mode
        build_orbital_infrastructure
      end
    end

    def large_moon?(moon)
      # Earth-style moon logic: check size, atmosphere, etc.
      moon.diameter_km > 3000 && moon.surface_gravity > 1.0
    end

    def build_surface_settlement
      # Create surface settlement for large moons
      @primary_settlement = Settlement::BaseSettlement.create!(
        name: "#{@target_world.name} Base",
        location: @target_world.location,
        settlement_type: :surface
      )
      puts "[ExpansionManager] Surface settlement created: #{@primary_settlement.name}" if @debug_mode
    end

    def convert_to_station_depot
      # Convert small moon into orbital station/depot
      @primary_settlement = Settlement::OrbitalDepot.create!(
        name: "#{@target_world.name} Depot",
        location: @target_world.location,
        operational_data: {
          'conversion_type' => 'moon_to_depot',
          'original_body' => @target_world.name
        }
      )
      puts "[ExpansionManager] Moon converted to depot: #{@primary_settlement.name}" if @debug_mode
    end

    def build_orbital_infrastructure
      # For planets, build orbital infrastructure
      @primary_settlement = Settlement::OrbitalDepot.create!(
        name: "#{@target_world.name} Orbital Hub",
        location: @target_world.location
      )
      puts "[ExpansionManager] Orbital infrastructure created: #{@primary_settlement.name}" if @debug_mode
    end

    def bootstrap_market_orders
      puts "[ExpansionManager] Opening order book for construction materials..." if @debug_mode

      # Create market orders for construction materials needed
      construction_materials = ['steel', 'aluminum', 'concrete', 'solar_panels', 'life_support_modules']

      construction_materials.each do |material|
        # Create buy orders for the settlement
        Market::Order.create!(
          orderable: @primary_settlement,
          resource: material,
          quantity: 1000, # Large initial order
          order_type: :buy,
          price: calculate_bootstrap_price(material)
        )
      end

      # If orders aren't filled within timeframe, trigger AstroLift logistics contract
      schedule_safety_net_contract

      puts "[ExpansionManager] Order book opened with #{construction_materials.size} material orders" if @debug_mode
    end

    def calculate_bootstrap_price(material)
      # Simplified pricing for bootstrap orders
      base_prices = {
        'steel' => 50,
        'aluminum' => 80,
        'concrete' => 20,
        'solar_panels' => 200,
        'life_support_modules' => 500
      }
      base_prices[material] || 100
    end

    def schedule_safety_net_contract
      # Schedule a job to check if orders are filled, and trigger logistics if not
      SafetyNetLogisticsJob.set(wait: 7.days).perform_later(@primary_settlement.id)
      puts "[ExpansionManager] Safety net logistics job scheduled" if @debug_mode
    end
  end
end