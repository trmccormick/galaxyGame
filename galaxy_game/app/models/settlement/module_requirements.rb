module Settlement
  class ModuleRequirements
    SEALING_MODULES = {
      primary_entrance: {
        airlocks: 1,
        docking_ports: 2,
        pressure_doors: 2
      },
      skylight: {
        surface_connectors: 1,
        pressure_seals: 1,
        utility_ports: 1
      },
      secondary_access: {
        airlocks: 1,
        pressure_doors: 1
      }
    }
  end
end