module AIManager
  class AtmosphericHarvesterService
    # Venus: H2 import, local methane production
    def venus_harvest(venus)
      h2_imported = import_h2(venus)
      methane_produced = produce_methane(venus, h2_imported)
      update_fuel_imports(venus, methane_produced)
      { h2_imported: h2_imported, methane_produced: methane_produced }
    end

    # Titan: Nitrogen/Methane collection
    def titan_harvest(titan)
      nitrogen = collect_nitrogen(titan)
      methane = collect_methane(titan)
      { nitrogen: nitrogen, methane: methane }
    end

    # SkimmerDockingProtocol: Skimmer docks with Cycler to transfer gases
    def skimmer_docking(skimmer, cycler, gases)
      if dockable?(skimmer, cycler)
        transfer_gases(skimmer, cycler, gases)
        true
      else
        false
      end
    end

    # Resource Allocation: Mark surplus for export if depot > 20% reserve
    def mark_exportable_surplus(depot)
      if depot[:reserve] > 0.2 * depot[:capacity]
        depot[:exportable_surplus] = true
      else
        depot[:exportable_surplus] = false
      end
    end

    # --- Helper methods ---
    def import_h2(venus)
      venus[:h2_imported] = true
      100 # units
    end

    def produce_methane(venus, h2_amount)
      methane = h2_amount * 0.8
      venus[:methane_produced] = methane
      methane
    end

    def update_fuel_imports(venus, methane_produced)
      venus[:fuel_imports_reduced] = methane_produced > 0
    end

    def collect_nitrogen(titan)
      titan[:nitrogen_collected] = 200
    end

    def collect_methane(titan)
      titan[:methane_collected] = 150
    end

    def dockable?(skimmer, cycler)
      skimmer[:docking_port] && cycler[:docking_port] && skimmer[:panel_config] == cycler[:panel_config]
    end

    def transfer_gases(skimmer, cycler, gases)
      cycler[:cargo] ||= {}
      gases.each do |gas, amount|
        cycler[:cargo][gas] ||= 0
        cycler[:cargo][gas] += amount
      end
      skimmer[:cargo] = {}
    end
  end
end
