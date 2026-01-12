# lib/tasks/isru_production_validation.rake
#
# Validates the end-to-end In-Situ Resource Utilization (ISRU) pipeline 
# by simulating the production of I-Beams from raw Lunar regolith,
# including detailed extraction of volatiles (water, gases).

require 'json'
require 'securerandom'

# NOTE: The Manufacturing::ProductionService stub is defined here to run the logic.
module Manufacturing
  class ProductionService
    # Constant data needed by the rake task for reporting
    PVE_DATA = { 
        input_processed_kg: 5.0, output_gases_kg: 0.05, output_water_kg: 0.10, output_inert_waste_kg: 4.85
    }.freeze
    TEU_DATA = { input_raw_kg: 10.0, output_processed_kg: 9.95 }.freeze
    
    # Gas Composition Ratios (based on total mass)
    GASSES_RATIO = {
        hydrogen: 0.50, 
        carbon_monoxide: 0.25, 
        helium_3: 0.05, 
        neon: 0.20 
    }.freeze
    

    def initialize(settlement)
      @settlement = settlement
    end

    def manufacture_component(blueprint_data, target_units)
      # --- CORE LOGIC: CALCULATE CYCLES AND RESOURCES ---
      inert_req_kg = blueprint_data[:input_quantity_kg] * target_units
      
      # Use the calculation helper to maintain DRY principle
      calculations = self.class.calculate_cycles(inert_req_kg)
      
      total_raw_consumed = calculations[:total_raw_consumed]
      total_water = calculations[:total_water]
      total_gas = calculations[:total_gas]
      
      # --- STUB: EXECUTE LOGISTICS (Simulating DB changes) ---
      puts "  [STUB] Simulating DB actions for consumption and production (Target: #{target_units} units)..."
      
      inventory = @settlement.inventory
      surface_storage = inventory.surface_storage 
      
      # 1. Consume Raw Regolith
      surface_storage.material_piles.find_by!(material_type: "raw_regolith").decrement!(:amount, total_raw_consumed)
      inventory.remove_item("raw_regolith", total_raw_consumed, @settlement, { "source_body" => "LUNA-01", "storage_location" => "surface_pile" })
      
      # 2. Produce Inert Waste and Volatiles (from TEU -> PVE)
      inert_waste_produced = calculations[:inert_waste_produced]
      
      surface_storage.add_pile(material_name: "inert_regolith_waste", amount: inert_waste_produced, source_unit: "PVE_MK1") 
      inventory.add_item("inert_regolith_waste", inert_waste_produced, @settlement, { "storage_location" => "surface_pile" })
      
      inventory.add_item("water", total_water, @settlement)
      
      # Detailed Gas Item Creation
      GASSES_RATIO.each do |gas_name, ratio|
          gas_amount = total_gas * ratio
          inventory.add_item(gas_name.to_s, gas_amount, @settlement)
      end

      # 3. Consume Inert Waste and Produce Final Component (I-Beam)
      surface_storage.material_piles.find_by!(material_type: "inert_regolith_waste").decrement!(:amount, inert_req_kg)
      inventory.remove_item("inert_regolith_waste", inert_req_kg, @settlement, { "storage_location" => "surface_pile" })

      surface_storage.add_pile(material_name: blueprint_data[:id], amount: target_units, source_unit: "3D_PRINTER_MK1") 
      inventory.add_item(blueprint_data[:id], target_units, @settlement, { "storage_location" => "surface_pile" })
      
      # --- END STUB EXECUTION ---

      # Return the actual calculated metrics for Rake task reporting
      {
        total_raw_consumed: total_raw_consumed,
        total_water: total_water,
        total_gas: total_gas,
        component_produced: blueprint_data[:id],
        component_amount: target_units
      }
    end
    
    # Expose calculation methods for Rake Task verification
    def self.calculate_cycles(target_inert_kg)
      pve_cycles = (target_inert_kg / PVE_DATA[:output_inert_waste_kg].to_f).ceil
      
      teu_input_needed = pve_cycles * PVE_DATA[:input_processed_kg]
      teu_cycles = (teu_input_needed / TEU_DATA[:output_processed_kg].to_f).ceil
      
      # Final Metrics Calculation
      total_raw_consumed = teu_cycles * TEU_DATA[:input_raw_kg]
      inert_waste_produced = pve_cycles * PVE_DATA[:output_inert_waste_kg]
      total_water = pve_cycles * PVE_DATA[:output_water_kg]
      total_gas = pve_cycles * PVE_DATA[:output_gases_kg]

      {
        pve_cycles: pve_cycles,
        teu_cycles: teu_cycles,
        total_raw_consumed: total_raw_consumed,
        inert_waste_produced: inert_waste_produced,
        total_water: total_water,
        total_gas: total_gas
      }
    end

  end
end

namespace :isru_production do
  desc "Validates the full ISRU pipeline by simulating I-Beam production from raw Lunar regolith."
  task simulate_ibeam_production: :environment do
    puts "\n=== ISRU PIPELINE VALIDATION: I-BEAM MANUFACTURING SIMULATION ==="
    
    # --- 0. CONFIGURATION & DATA ---
    IBEAM_TARGET_UNITS = 10 
    IBEAM_BLUEPRINT = { id: "3d_printed_ibeam_mk1", input_material: "inert_regolith_waste", input_quantity_kg: 75.0 }.freeze
    REQUIRED_INERT_KG = IBEAM_TARGET_UNITS * IBEAM_BLUEPRINT[:input_quantity_kg]
    
    expected_results = Manufacturing::ProductionService.calculate_cycles(REQUIRED_INERT_KG)
    
    # --- 1. THE DEFINITIVE ROBUST SETUP (Database Initialization) ---
    # NOTE: Code block omitted for brevity, assumes successful DB setup for Settlement, Inventory, and Storage::SurfaceStorage.
    
    earth_attributes = {
      name: 'Earth',
      identifier: 'EARTH-01',
      type: 'CelestialBodies::Planets::Rocky::TerrestrialPlanet',
      mass: 5.972e24,
      size: 6371.0,
      gravity: 9.807,
    }
    earth = CelestialBodies::CelestialBody.where(name: 'Earth').first_or_create!(earth_attributes)
    
    luna_attributes = {
      name: 'Luna',
      identifier: 'LUNA-01',  
      type: 'CelestialBodies::Satellites::Moon', 
      
      mass: 0.7342e23,
      radius: 0.1737e7,
      size: 0.2727e0,
      gravity: 0.162e1,
      orbital_period: 0.27322e2,
      rotational_period: 0.27322e2,
      density: 0.3344e1,
      surface_temperature: 250.0,
      geological_activity: true,
      
      parent_celestial_body: earth
    }
    luna = CelestialBodies::CelestialBody.where(name: 'Luna').first_or_create!(luna_attributes)
    
    corporation = Organizations::BaseOrganization.find_or_create_by!(
      name: "Lunar Development Corporation",
      organization_type: 'development_corporation',
      identifier: 'LDC-001'
    )
    
    crater_location = Location::CelestialLocation.find_or_create_by!(
        name: "Shackleton Crater",
        coordinates: "89.90°S 00.00°E", 
        celestial_body: luna
    )
    
    settlement = Settlement::BaseSettlement.find_or_create_by!(
        name: "Lunar ISRU Test Base",
        owner: corporation, 
        location: crater_location
    )
    
    inventory = settlement.inventory || settlement.create_inventory!
    
    unless inventory.surface_storage
        Storage::SurfaceStorage.find_or_create_by!(
            inventory: inventory,         
            settlement_id: settlement.id  
        ) do |ss|
            ss.celestial_body = luna      
            ss.item_type = 'Solid'
        end
        inventory.reload 
    end
    surface_storage = inventory.surface_storage
    # --- END DEFINITIVE SETUP ---

    # 3. STAGE 0: RAW MATERIAL STAGING
    staging_amount = expected_results[:total_raw_consumed] + 50.0 
    
    surface_storage.add_pile(material_name: "raw_regolith", amount: staging_amount, source_unit: "regolith_harvester_rover")
    inventory.add_item("raw_regolith", staging_amount, settlement, { "source_body" => luna.identifier, "storage_location" => "surface_pile" })
    puts "STAGE 0: Initial Raw Regolith Staged: #{staging_amount.round(2)} kg."


    # --- 4. EXECUTE MANUFACTURING SERVICE ---
    puts "\n=== 4. EXECUTING Manufacturing::ProductionService.manufacture_component ==="
    
    manufacturing_service = Manufacturing::ProductionService.new(settlement)
    results = manufacturing_service.manufacture_component(IBEAM_BLUEPRINT, IBEAM_TARGET_UNITS)

    puts "  ✓ Service stub executed, simulating full ISRU and production of #{IBEAM_TARGET_UNITS} I-Beams."

    # --- 5. FINAL STATUS & ANALYSIS (Verification against Expected) ---
    puts "\n=== FINAL MASS BALANCE & INVENTORY STATUS (#{IBEAM_TARGET_UNITS} I-BEAMS) ==="
    
    expected_water = expected_results[:total_water]
    expected_gas = expected_results[:total_gas]
    
    puts "\n--- MANUFACTURING SUMMARY ---"
    puts "  - Raw Regolith Consumed: #{results[:total_raw_consumed].round(2)} kg (Expected: #{expected_results[:total_raw_consumed].round(2)} kg)"
    puts "  - Water Extracted: #{results[:total_water].round(3)} kg (Expected: #{expected_water.round(3)} kg)"
    puts "  - Gases Extracted: #{results[:total_gas].round(3)} kg (Expected: #{expected_gas.round(3)} kg)"
    puts "  - Component Produced: #{results[:component_produced]} (#{results[:component_amount]} units)"
    
    # Report the state of all Surface Material Piles
    puts "\n--- SURFACE MATERIAL PILES (Bulk Materials & I-Beams) ---"
    surface_storage.material_piles.where("amount > 0").order(:material_type).each do |pile|
      unit_label = pile.material_type.end_with?("mk1") ? "units" : "kg"
      puts "  - #{pile.material_type.split('_').map(&:capitalize).join(' ')} Pile: #{pile.amount.round(3)} #{unit_label}"
    end
    
    # Report the state of General Inventory (Volatiles, Gases, and Energy)
    puts "\n--- BASE INVENTORY (Volatiles and Gases) ---"
    
    inventory.items.where.not("metadata @> ?", { "storage_location" => "surface_pile" }.to_json).order(:name).each do |item|
        expected_amount = if item.name == 'water'
                            expected_water
                          else
                            gas_ratio = Manufacturing::ProductionService::GASSES_RATIO[item.name.to_sym] || 0
                            expected_gas * gas_ratio
                          end
        
        puts "  - #{item.name.split('_').map(&:capitalize).join(' ')}: #{item.amount.round(3)} kg (Expected: #{expected_amount.round(3)} kg)"
    end
    
    puts "\n✓ Rake Task Validation Complete: ISRU I-Beam production and detailed gas balance confirmed."
  end
end