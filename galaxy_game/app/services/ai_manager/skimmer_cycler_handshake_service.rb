module AIManager
  class SkimmerCyclerHandshakeService
    # Dock skimmer to cycler during high-speed transit
    def dock_skimmer(skimmer, cycler)
      return false unless compatible?(skimmer, cycler)
      return false unless cycler.has_unit?(:docking_hub)
      return false unless cycler.dock(skimmer)
      true
    end

    # Primary entry point — routes to variant-specific processing logic
    def process_cargo(vessel, target)
      variant = identify_vessel_variant(vessel)
      
      case variant
      when :harvester
        ensure_correct_variant(vessel, :harvester) || return false
        process_cargo_harvester(vessel, target)
      when :tanker
        ensure_correct_variant(vessel, :tanker) || return false
        process_cargo_tanker(vessel, target)
      else
        Rails.logger.error("SkimmerCyclerHandshakeService: Unknown vessel variant: #{variant}")
        false
      end
    end

    # Real atmospheric extraction — replaces mock harvester data
    def execute_atmospheric_extraction(skimmer, source_body, target_body: nil, capacity: nil)
      extraction = AIManager::AtmosphericExtractionService.new(skimmer, source_body, target_body: target_body)
      result = extraction.execute_extraction(capacity: capacity || skimmer.atmosphere&.total_atmospheric_mass || 5000)

      # Offload to cycler after successful extraction
      if result[:success] && skimmer.docked_at.is_a?(Craft::Transport::Cycler)
        extraction.dock_and_transfer_to_cycler(skimmer.docked_at)
      end

      result
    end

    # Vessel identification — prerequisite step before any processing
    def identify_vessel_variant(vessel)
      # Method 1: Check operational_data flag (preferred)
      return vessel.operational_data[:vessel_variant] if vessel.respond_to?(:operational_data) && vessel.operational_data[:vessel_variant]
      
      # Method 2: Check blueprint compatible_units
      blueprint = LookupService.find_blueprint(vessel.blueprint_id) rescue nil
      if blueprint&.compatible_units&.include?('atmospheric_harvester_system')
        :harvester
      elsif blueprint&.compatible_units&.include?('cryogenic_storage_unit')
        :tanker
      else
        # Method 3: Check module configuration
        cryo_count = vessel.modules.count { |m| m.type == 'cryogenic_storage_unit' } rescue 0
        if cryo_count >= 8
          :tanker
        elsif vessel.modules.any? { |m| m.type == 'atmospheric_harvester_system' } rescue false
          :harvester
        else
          # Default: assume harvester (most common variant)
          :harvester
        end
      end
    end

    # Harvester Variant — Limited onboard processing for fuel-tank refilling only
    def process_cargo_harvester(skimmer, cycler)
      return false unless cycler.docked_at == skimmer || cycler.docked_at&.id == skimmer.id
      
      # Calculate fuel needed for next transit leg (NOT full cargo processing)
      fuel_needed = calculate_fuel_tank_refill(skimmer)
      
      # Process ONLY enough raw cargo to refill fuel tanks (MVP design constraint)
      return false if skimmer.raw_cargo.values.sum < fuel_needed
      
      # Deduct from raw cargo proportionally (preserving remaining cargo for Depot offload)
      processed_amount = deduct_from_raw_cargo(skimmer.raw_cargo, fuel_needed)
      
      # Refill fuel tanks from processed gas
      skimmer.fuel_tanks.refill(processed_amount) if skimmer.respond_to?(:fuel_tanks)
      
      # Mark for Depot offload (NOT available for next dive until docked at Depot)
      skimmer.available = false
      skimmer.next_target = :depot
      
      true
    end

    # Tanker Variant — Bulk transport with Depot refueling (NOT onboard processing)
    def process_cargo_tanker(tanker, depot)
      return false unless tanker.docked_at == depot || tanker.docked_at&.id == depot.id
      
      # Offload cargo to Depot cryo tanks (NOT processed onboard)
      offloaded = depot.receive_cargo(tanker.raw_cargo) if depot.respond_to?(:receive_cargo)
      tanker.raw_cargo = {}
      
      # Refuel from Depot reserves (NOT from onboard processing)
      refueled = depot.refuel_vehicle(tanker, fuel_types: [:lox, :methane]) if depot.respond_to?(:refuel_vehicle)
      
      # Load new cargo for next leg based on logistics_priority routing
      tanker.load_cargo(depot.available_cargo, priority: tanker.logistics_priority) if depot.respond_to?(:available_cargo) && tanker.respond_to?(:load_cargo)
      
      true
    end

    # Depot detection trigger — proximity check via AI Manager routing system
    def detect_nearby_depots(vessel)
      ai_manager = AIManager.instance rescue nil
      return [] unless ai_manager
      
      ai_manager.find_nearby_depots(vessel.current_position) rescue []
    end

    # Ensure correct variant before processing (error handling for wrong variant execution)
    def ensure_correct_variant(vessel, expected_variant)
      actual = identify_vessel_variant(vessel)
      if actual != expected_variant
        Rails.logger.error("SkimmerCyclerHandshakeService: Vessel #{vessel.id} is #{actual} variant, expected #{expected_variant}")
        return false
      end
      true
    end

    # Panel/I-Beam compatibility using Craft panel system
    def compatible?(skimmer, cycler)
      skimmer.panel_config == cycler.operational_data.dig('panel_config')
    end

    private

    # Calculate fuel needed for next transit leg (derived from compatible unit blueprints)
    def calculate_fuel_tank_refill(skimmer)
      # Derive from compatible unit blueprints or operational_data
      if skimmer.respond_to?(:fuel_tanks) && skimmer.fuel_tanks.respond_to?(:capacity) && skimmer.fuel_tanks.respond_to?(:current)
        skimmer.fuel_tanks.capacity.values.sum - skimmer.fuel_tanks.current.values.sum
      else
        # Fallback: assume 10% of raw cargo mass for fuel refilling (MVP approximation)
        (skimmer.raw_cargo.values.sum * 0.1).round(2)
      end
    end

    # Deduct proportionally from raw cargo across all gas types
    def deduct_from_raw_cargo(raw_cargo, amount)
      total = raw_cargo.values.sum
      return 0 if total == 0
      
      processed = {}
      remaining = amount
      raw_cargo.each do |gas, mass|
        portion = (mass / total * amount).round(2)
        processed[gas] = [portion, mass].min
        remaining -= portion
        break if remaining <= 0
      end
      
      # Update skimmer's raw cargo
      raw_cargo.each_key { |gas| raw_cargo[gas] -= (processed[gas] || 0) }
      
      processed.values.sum
    end
  end
end
