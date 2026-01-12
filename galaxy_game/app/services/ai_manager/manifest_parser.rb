# app/services/ai_manager/manifest_parser.rb
module AIManager
  class ManifestParser
    def extract_equipment_from_manifest(manifest_file)
      manifest = load_json(manifest_file)

      return {} if manifest.empty?

      {
        craft_fit: extract_craft_fit(manifest["craft"]),
        inventory: extract_inventory(manifest["inventory"]),
        economic_profile: calculate_economics(manifest)
      }
    end

    def extract_craft_fit(craft_data)
      return {} unless craft_data

      # Handle both recommended_fit and installed_units
      fit_data = craft_data["recommended_fit"] || craft_data["installed_units"]

      return {} unless fit_data

      if fit_data.is_a?(Array)
        # installed_units format
        units = fit_data.map do |unit|
          "#{unit['name']} (#{unit['count']})"
        end
        {
          modules: [],
          units: units,
          total_modules: 0,
          total_units: fit_data.sum { |u| u["count"].to_i }
        }
      else
        # recommended_fit format
        {
          modules: extract_modules(fit_data["modules"]),
          units: extract_units(fit_data["units"]),
          total_modules: fit_data["modules"]&.sum { |m| m["count"].to_i } || 0,
          total_units: fit_data["units"]&.sum { |u| u["count"].to_i } || 0
        }
      end
    end

    def extract_inventory(inventory_data)
      return {} unless inventory_data

      {
        deployable_units: extract_deployable_units(inventory_data["units"]),
        supplies: extract_supplies(inventory_data["supplies"]),
        consumables: extract_consumables(inventory_data["consumables"]),
        total_mass: calculate_total_mass(inventory_data)
      }
    end

    def calculate_economics(manifest)
      return {} unless manifest["inventory"]

      supplies = manifest["inventory"]["supplies"] || []
      consumables = manifest["inventory"]["consumables"] || []

      earth_imports = identify_earth_imports(supplies)
      local_potential = identify_local_production(consumables)

      {
        path: determine_path(earth_imports, local_potential),
        import_ratio: supplies.empty? ? 0 : earth_imports.size.to_f / supplies.size,
        estimated_cost: calculate_gcc_cost(manifest),
        earth_import_items: earth_imports,
        local_production_items: local_potential
      }
    end

    private

    def load_json(file_path)
      JSON.parse(File.read(file_path))
    rescue JSON::ParserError, Errno::ENOENT
      {}
    end

    def extract_modules(modules_data)
      return [] unless modules_data

      modules_data.map do |module_data|
        "#{module_data['id']} (#{module_data['count']})"
      end
    end

    def extract_units(units_data)
      return [] unless units_data

      units_data.map do |unit_data|
        "#{unit_data['id']} (#{unit_data['count']})"
      end
    end

    def extract_deployable_units(units_data)
      return [] unless units_data

      units_data.map do |unit|
        "#{unit['name']} (#{unit['count']})"
      end
    end

    def extract_supplies(supplies_data)
      return [] unless supplies_data

      supplies_data.map do |supply|
        "#{supply['id']} (#{supply['count']} #{supply['unit']})"
      end
    end

    def extract_consumables(consumables_data)
      return [] unless consumables_data

      consumables_data.map do |consumable|
        amount = consumable['amount'] || consumable['count'] || 0
        "#{consumable['id']} (#{amount} #{consumable['unit']})"
      end
    end

    def calculate_total_mass(inventory_data)
      total_kg = 0

      # Supplies mass
      if inventory_data["supplies"]
        inventory_data["supplies"].each do |supply|
          count = supply["count"].to_f
          unit = supply["unit"]
          total_kg += count if unit == "kilogram"
        end
      end

      # Consumables mass (most are kg)
      if inventory_data["consumables"]
        inventory_data["consumables"].each do |consumable|
          amount = consumable["amount"] || consumable["count"] || 0
          unit = consumable["unit"]
          total_kg += amount.to_f if unit == "kilogram"
        end
      end

      "#{total_kg.to_i} kg"
    end

    def identify_earth_imports(supplies)
      # Items that typically come from Earth
      earth_items = [
        "enriched_uranium_fuel",
        "nuclear_grade_zirconium",
        "radiation_shielding_material",
        "advanced_sensors",
        "heat_shields",
        "radiation_shielding"
      ]

      supplies.select do |supply|
        earth_items.include?(supply["id"])
      end.map { |s| s["id"] }
    end

    def identify_local_production(consumables)
      # Items that can be produced locally via ISRU
      local_items = [
        "methalox_fuel",
        "liquid_methane",
        "liquid_oxygen",
        "water"
      ]

      consumables.select do |consumable|
        local_items.include?(consumable["id"])
      end.map { |c| c["id"] }
    end

    def determine_path(earth_imports, local_potential)
      earth_ratio = earth_imports.size.to_f / [earth_imports.size + local_potential.size, 1].max

      if earth_ratio > 0.6
        "A (Complete Modules)" # High Earth dependency
      elsif earth_ratio > 0.3
        "B (Seed Equipment)" # Mixed approach
      else
        "C (Hybrid)" # Mostly local production
      end
    end

    def calculate_gcc_cost(manifest)
      # Rough cost estimation based on manifest contents
      base_cost = 500000 # Base mission cost

      # Add cost for supplies
      if manifest["inventory"] && manifest["inventory"]["supplies"]
        supply_cost = manifest["inventory"]["supplies"].sum do |supply|
          # Rough cost per kg for different materials
          cost_per_kg = case supply["id"]
          when "enriched_uranium_fuel" then 5000
          when "titanium_alloy" then 1000
          when "carbon_nanotube_material" then 2000
          else 500
          end
          supply["count"].to_f * cost_per_kg
        end
        base_cost += supply_cost
      end

      # Add cost for consumables
      if manifest["inventory"] && manifest["inventory"]["consumables"]
        consumable_cost = manifest["inventory"]["consumables"].sum do |consumable|
          # Rough cost per kg for consumables
          cost_per_kg = case consumable["id"]
          when "methalox_fuel" then 50
          when "water" then 10
          when "food_rations" then 100 # per day
          else 20
          end
          consumable["count"].to_f * cost_per_kg
        end
        base_cost += consumable_cost
      end

      base_cost.to_i
    end
  end
end