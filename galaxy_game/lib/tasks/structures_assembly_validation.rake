# lib/tasks/structures_assembly_validation.rake

require 'json'
require 'securerandom'

# --- PURE RUBY INSTANCE METHOD STUBBING IMPLEMENTATION ---
def self.stub_instance_method(klass, method_name, stub_block)
  # ... (Instance method stubbing helper remains unchanged) ...
  original_method_alias = "original_#{method_name}_for_stubbing".to_sym
  
  klass.send(:alias_method, original_method_alias, method_name)
  
  klass.send(:define_method, method_name, stub_block)

  return lambda do 
    klass.send(:alias_method, method_name, original_method_alias)
    klass.send(:remove_method, original_method_alias)
  end
rescue NameError
  puts "WARNING: Method '#{method_name}' was not found on #{klass}. Cannot stub."
  return lambda {}
end

# Let's adjust the class method helper to not rely on original existence:
def self.stub_class_method_resilient(klass, method_name, stub_block)
  original_method = klass.respond_to?(method_name) ? klass.method(method_name) : nil
  
  # Define the new stub method
  klass.define_singleton_method(method_name, stub_block)

  # Return a block to restore the original method
  return lambda do 
    if original_method
      klass.define_singleton_method(method_name, original_method)
    else
      # Re-define the method to raise a clear error if it was dynamically added/removed
      klass.define_singleton_method(method_name, ->(*args) { raise NoMethodError, "Restored method not found." })
    end
  end
rescue NameError => e
  puts "ERROR in stub_class_method_resilient for #{klass}.#{method_name}: #{e.message}"
  return lambda {}
end

# --- CORE LOGIC FOR RAKE TASK ---

namespace :structures do
  desc "Validates that new orbital structures (Mega Stations, Depots) are correctly assembled with recommended internal components using pure Ruby stubbing."
  task validate_assembly: :environment do
    puts "\n=== STRUCTURE ASSEMBLY VALIDATION: ORBITAL BASE CONSTRUCTION (PURE RUBY STUB) ==="
    
    # ... (Configuration, MOCK_HUB_DATA, and setup logic remains the same) ...
    PLANETARY_HUB_ID = "planetary_staging_hub_mk1"
    
    MOCK_HUB_DATA = {
      "id" => PLANETARY_HUB_ID,
      "name" => "Planetary Staging Hub",
      "structure_type" => "mega_station",
      "blueprint_data" => {
        "materials" => [
          { "id" => "modular_structural_panel_base", "amount" => 5000, "unit" => "unit" }
        ],
        "research_required" => "mega_structure_assembly_4"
      },
      "recommended_units" => [
        { "id" => "nuclear_reactor_fusion", "count" => 4, "category" => "energy" },
        { "id" => "control_computer_quantum", "count" => 2, "category" => "control" }
      ],
      "recommended_modules" => [
        { "id" => "shipyard_assembly_module", "count" => 2, "category" => "manufacturing" },
        { "id" => "large_habitat_module", "count" => 4, "category" => "habitat" }
      ],
      "metadata" => {
        "template_compliance" => "orbital_structure_operational_data_v1"
      }
    }.freeze

    cleanup_routines = [] 
    
    begin
      
      # 1. STUB Lookup::StructureLookupService.new to return a mock with find_structure
      MockLookupService = Struct.new(:id) do
        def find_structure(structure_id, category=nil)
          if structure_id == PLANETARY_HUB_ID
            puts "--- MOCK INTERCEPT: Structure Lookup Service stub successful! ---"
            return MOCK_HUB_DATA
          end
          nil
        end
      end

      cleanup_routines << self.stub_class_method_resilient(Lookup::StructureLookupService, :new, lambda do
        MockLookupService.new
      end)
      
      # 2. STUB Lookup::UnitLookupService to return mock unit data
      MockUnitLookupService = Struct.new(:id) do
        def find_unit(unit_id)
          case unit_id
          when "nuclear_reactor_fusion"
            { "id" => "nuclear_reactor_fusion", "name" => "Nuclear Reactor Fusion" }
          when "control_computer_quantum"
            { "id" => "control_computer_quantum", "name" => "Control Computer Quantum" }
          else
            nil
          end
        end
      end
      
      cleanup_routines << self.stub_class_method_resilient(Lookup::UnitLookupService, :new, lambda do
        MockUnitLookupService.new
      end)
      
      # 3. STUB Lookup::ModuleLookupService to return mock module data
      MockModuleLookupService = Struct.new(:id) do
        def find_module(module_id)
          case module_id
          when "shipyard_assembly_module"
            { "id" => "shipyard_assembly_module", "name" => "Shipyard Assembly Module" }
          when "large_habitat_module"
            { "id" => "large_habitat_module", "name" => "Large Habitat Module" }
          else
            nil
          end
        end
      end
      
      cleanup_routines << self.stub_class_method_resilient(Lookup::ModuleLookupService, :new, lambda do
        MockModuleLookupService.new
      end)
      
      # --- 4. Setup Base Objects (Database Initialization) ---
      corporation = Organizations::BaseOrganization.find_or_create_by!(name: "Assembly Test Corp", identifier: 'ATC-001')
      
      # 🚨 FIX 1: LUNA CRASH FIX
      # Use find_by first to avoid trying to create the object a second time, which violates validations.
      luna = CelestialBodies::CelestialBody.find_by(name: 'Luna', identifier: 'LUNA-01', type: 'CelestialBodies::Satellites::Moon')
      
      unless luna
        luna = CelestialBodies::CelestialBody.create!(
          name: 'Luna',
          identifier: 'LUNA-01',
          type: 'CelestialBodies::Satellites::Moon',
          size: 3474.8,
          mass: 7.346e22 # Must be scientific notation for Float precision
        )
      end
      
      location = Location::CelestialLocation.find_or_create_by!(
          name: "Test Orbit", 
          celestial_body: luna,
          coordinates: "00.00°N 00.00°E" 
      )
      
      settlement = Settlement::BaseSettlement.find_or_create_by!(
          name: "Orbital Test Site",
          owner: corporation, 
          location: location
      )
      
      puts "✓ Class method stubs set up using resilient Ruby aliasing."
      
      # --- 5. EXECUTE STRUCTURE CREATION ---
      puts "\n--- 5. Building Planetary Staging Hub (#{PLANETARY_HUB_ID}) ---"
      
      structure = nil
      # Ensure the BaseStructure is created and assembled within the same transactional context
      ActiveRecord::Base.transaction do
          structure = Structures::BaseStructure.create!(
              name: "PSH-TEST-#{SecureRandom.hex(4)}", 
              structure_name: PLANETARY_HUB_ID, 
              owner: settlement.owner,
              settlement: settlement,
              location: settlement.location,
              operational_data: MOCK_HUB_DATA.deep_dup 
          ) 
          
          # Build recommended units and modules
          structure.build_recommended_units
          structure.build_recommended_modules
          puts "  [INFO] Built recommended units and modules."
      end
          
      puts "  [INFO] BaseStructure (ID: #{structure.id}) created."
      
      # --- 6. VALIDATION & ANALYSIS (Verification logic remains the same) ---
      
      # A. Validate Operational Data Loading
      puts "\n--- 6. VALIDATING DATA AND ASSEMBLY ---"
      
      # ... (Validation logic unchanged) ...
      if structure.operational_data.present? && structure.operational_data['structure_type'] == 'mega_station'
        puts "✓ Operational Data Loaded: structure_type is '#{structure.operational_data['structure_type']}'."
      else
        puts "✗ ERROR: Operational Data missing or incorrect. Found: #{structure.operational_data.inspect}"
      end
      
      # B. Validate Total Component Count (using actual database queries)
      actual_units = structure.units.reload
      actual_modules = structure.modules.reload
      
      total_expected_modules = MOCK_HUB_DATA["recommended_modules"].sum { |m| m["count"] }
      total_expected_units = MOCK_HUB_DATA["recommended_units"].sum { |u| u["count"] }
      
      puts "  Expected Modules: #{total_expected_modules}"
      puts "  Actual Modules Created: #{actual_modules.count}"
      puts "  Expected Units: #{total_expected_units}"
      puts "  Actual Units Created: #{actual_units.count}"
      
      # C. Validate Specific Component Creation
      
      shipyard_count = actual_modules.count { |m| m.module_type == "shipyard_assembly_module" }
      habitat_count = actual_modules.count { |m| m.module_type == "large_habitat_module" }
      reactor_count = actual_units.count { |u| u.unit_type == "nuclear_reactor_fusion" }
      control_count = actual_units.count { |u| u.unit_type == "control_computer_quantum" }

      
      # Report Results
      puts "\n--- SPECIFIC COMPONENT VERIFICATION ---"
      
      check_pass = true
      
      # ... (Specific check logic unchanged) ...
      if shipyard_count == 2
        puts "✓ Shipyard Assembly Module: Expected 2, Found 2."
      else
        puts "✗ ERROR: Shipyard Assembly Module: Expected 2, Found #{shipyard_count}."
        check_pass = false
      end
      
      if habitat_count == 4
        puts "✓ Large Habitat Module: Expected 4, Found 4."
      else
        puts "✗ ERROR: Large Habitat Module: Expected 4, Found #{habitat_count}."
        check_pass = false
      end

      if reactor_count == 4
        puts "✓ Nuclear Reactor Fusion: Expected 4, Found 4."
      else
        puts "✗ ERROR: Nuclear Reactor Fusion: Expected 4, Found #{reactor_count}."
        check_pass = false
      end
      
      if control_count == 2
        puts "✓ Control Computer Quantum: Expected 2, Found 2."
      else
        puts "✗ ERROR: Control Computer Quantum: Expected 2, Found #{control_count}."
        check_pass = false
      end
      
      puts "\n=== Rake Task Validation Complete. All components assembled: #{check_pass ? 'PASS' : 'FAIL'} ==="
      
      # Clean up the created records in correct order (structure first, then settlement, then location)
      structure.destroy!
      settlement.destroy!
      corporation.destroy!
      location.destroy!

    ensure
      # --- RESTORE ORIGINAL METHODS ---
      puts "\n[CLEANUP] Restoring original class methods..."
      cleanup_routines.each(&:call)
    end
    
  end
end