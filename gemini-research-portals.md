Portal Technology Master Design Specification & Review PackageHere is the comprehensive master design specification structured as a clean Markdown document. You can save this directly as PORTAL_TECHNOLOGY_MASTER_DESIGN.md to pass to Claude or use for cross-referencing against your local workstation documentation.Galaxy Game — Portal Technology Master Design SpecificationStatus: Canonical Design Draft / Review PackageTarget Architecture: Ruby on Rails Backend / Deterministic Background ProcessingCompliance Standards: Unit Blueprint v1.4, Unit Operational Data v1.3   1. Technological Foundations & Tech Tree PlacementPortal technology is classified under Level 4 of the EM Technology Tree and is strictly gated behind Level 3 (Artificial Wormhole Station / AWS) deployment and advanced miniaturization research.   Derivative of Quantum Entanglement: Unlike macro-scale natural wormholes or AWS rifts that require planetary-scale mass anchors (gas giants/brown dwarfs) and gigawatt-scale Exotic Matter (EM), Level 4 portals utilize quantum entanglement to pair two physical gate endpoints.   Energy Profile: Operated via micro-doses of Exotic Matter resonance (e.g., $0.0125\text{ kg/hr}$ for an intra-system Mk I gate) coupled with standard electrical power feeds ($1,200\text{ kW}$).Scope Restriction (Level 4a vs 4b):Level 4a (Intra-System): Direct point-to-point transit within a single solar system (e.g., Sol network under a Three-Link structural constraint model).   Level 4b (Inter-System Hubs): Portal gates installed directly at AWS stations to provide player jump transit across known interstellar wormhole routes (EVE-style gate travel).   2. Structural & Mass ConstraintsPortals are physically low-mass devices, but their operational spatial mechanics require robust engineering integration:   Hull Class Minimums: Portals cannot be mounted to arbitrary, lightweight hulls (such as small scouts, light miners, or utility shuttles). Only capital-class vessels, heavy freighters, mobile base hulls, or dedicated space stations possess the structural dry mass and inertial stability required.   Spine & Keel Siting: On ships and stations, the portal chassis must tie directly into the primary structural spine or reinforced keel to absorb transfer torque, momentum shifts, and spatial-mechanical stress during activation.   Paired Requirement: Portals must be deployed strictly in verified entangled pairs (partner_id). Single or unpaired portals are non-functional.   3. Operational Safety, Airlock Vestibules, and TelemetryTo prevent catastrophic decompression or structural blowouts, portal installations must adhere to strict environmental safety standards:Airlock Vestibule Best Practice: Recommended engineering standards dictate housing portals inside dedicated, bulkhead-isolated airlock rooms. This isolates local zones, enables controlled pressure cycling, and permits residual gas recovery during maintenance.   Human-Rated Interlocks: Human-accessible portals are monitored in-tick for physiological safety bands ($0.7\text{--}1.2\text{ atm}$) and rate-of-change ($dP/dt$) pressure spikes.   Automated Safety Triggers: Exceeding safety thresholds automatically trips emergency bulkhead shutoffs and pneumatic gas recovery manifolds.NPC vs. Player Agency: NPC settlements enforce strict airlock compliance. Players have full agency to weld raw gateways straight into primary corridors, accepting the full operational risk of unbuffered pressure events.   4. Macro-Economic Boundaries: Portals vs. Cyclers vs. Mass DriversTo preserve the deep economic and industrial simulation loops of Galaxy Game, strict functional boundaries are enforced:Not Bulk Shippers: Portals are explicitly restricted to personnel, data, and small, high-value cargo. They do not replace interplanetary cyclers, heavy freighters, or bulk atmospheric pipelines.   Terraforming Separation: Portals cannot handle the staggering mass volumes required for planetary terraforming (e.g., Venus-to-Mars mass-driver carbon-nanotube volatile canisters or cycler fleets). Terraforming remains a macro-scale background engine managed via Development Corporation footholds and GCC budgets.   Logistics Arteries: Portals act as shared supply lines distributing tactical personnel and vital components, but every base must maintain an independent full life-support backbone. If a portal link drops, bases cannot rely on external air streams to survive.   5. Schema Compliance & Implementation MappingA. Unit Blueprint (unit_blueprint_v1.4.json)Category / Subcategory: infrastructure / transport_node   Physical Profile: $6.5\text{m} \times 6.5\text{m} \times 3.2\text{m}$, empty mass $18,500\text{ kg}$, volume $135\text{ m}^3$.   Required Materials: Superconducting magnets, carbon-nanotube composites, quantum entanglement nodes, structural I-beams, and EM containment lining.   Connection Schema: Requires mounting slots tied to heavy_structural_flange (base keel) and pressure_vestibule_seal (ingress face).   B. Operational Data (unit_operational_data_v1.3.json)Consumables: $1,200\text{ kWh}$ electrical power + $0.0125\text{ kg/hr}$ Exotic Matter.   Habitat Systems: Human-accessible (capacity: 12 occupants, $135\text{ m}^3$ volume, $101.3\text{ kPa}$ nominal pressure, $0.85$ radiation shielding).   Diagnostics & Telemetry: 10.0 Hz logging frequency tracking $dP/dt$ sensor deltas, entanglement resonance (Hz), and structural torque (kN).   6. Areas Recommended for Documentation Review & Gap CheckingBefore final sign-off, cross-reference this specification against your local workspace documentation for potential tuning in the following areas:Three-Link Sol Constraint Logic: Verify whether the controller-level enforcement for Sol's network limit is fully documented in the backend routing service (WormholeNavigator) or if explicit database table constraints are needed.   Maintenance Part Supply Chains: Ensure that replacement quantum entanglement nodes and superconducting magnets have defined manufacturing loops within the early-to-mid game industrial tree (Luna/L1 Shipyard).Decommissioning / Flow Reversal Mechanics: Confirm whether the reverse-flow gas recovery protocol for retiring habitats has its background service job fully stubbed out in the Rails architecture specs.

---------
1. Blueprint Specification (unit_blueprint_v1.4.json compliance)
{
  "template": "unit_blueprint",
  "id": "portal_gate_mk1",
  "name": "Mk I Intra-System Portal Gate",
  "description": "Quantum-entangled paired portal terminal for high-precision, low-mass arterial logistics and personnel transit within a solar system. Requires heavy structural spine anchoring and a bulkhead-isolated airlock vestibule.",
  "category": "infrastructure",
  "subcategory": "transport_node",
  "port_type": "heavy_structural_flange",

  "physical_properties": {
    "length_m": 6.5,
    "width_m": 6.5,
    "height_m": 3.2,
    "empty_mass_kg": 18500.0,
    "volume_m3": 135.0
  },

  "item_produced": {
    "id": "portal_gate_mk1",
    "amount": 1,
    "unit": "unit"
  },

  "required_materials": {
    "superconducting_magnets": {
      "amount": 2500,
      "unit": "kilogram"
    },
    "carbon_nanotube_composite": {
      "amount": 4200,
      "unit": "kilogram"
    },
    "quantum_entanglement_nodes": {
      "amount": 4,
      "unit": "unit"
    },
    "heavy_structural_i_beams": {
      "amount": 3500,
      "unit": "kilogram"
    },
    "exotic_matter_containment_lining": {
      "amount": 800,
      "unit": "kilogram"
    }
  },

  "production_data": {
    "time_hours": 336,
    "power_consumption_kw": 1200,
    "required_facility_type": "orbital_shipyard_heavy_bay",
    "required_technology": "portal_technology_level_4a",
    "base_material_efficiency": 1.0,
    "base_time_efficiency": 1.0
  },

  "cost_data": {
    "purchase_cost": {
      "currency": "GCC",
      "amount": 450000
    },
    "maintenance": {
      "time_to_repair_hours": 24,
      "repair_cost_gcc": 15000,
      "materials_needed_for_repair": ["quantum_entanglement_nodes", "superconducting_magnets"]
    }
  },

  "byproducts": [],

  "hazard_level": 3,
  "special_handling": ["zero_g_alignment", "exotic_matter_shielding", "magnetic_quench_protocols"],

  "operational_data_reference": {
    "file": "data/json-data/operational_data/units/portal_gate_mk1_ops.json",
    "operational_properties": {
      "em_consumption_rate_mg_hr": 12.5,
      "max_throughput_mass_kg_hr": 5000.0,
      "human_rated": true
    }
  },

  "storage_properties": {
    "capacity": 0,
    "stored_material": "none",
    "phase": "solid",
    "requires_cooling": true
  },

  "deployment_data": {
    "deployable": true,
    "printer_required": false,
    "requires_shell": false,
    "default_deployment_time_hours": 48
  },

  "connection_schema": {
    "mounting_slots": [
      { "slot_id": "spine_mount_primary", "bus_type": "heavy_structural_flange", "location": "base_keel" },
      { "slot_id": "airlock_interface", "bus_type": "pressure_vestibule_seal", "location": "ingress_face" },
      { "slot_id": "em_feed_line", "bus_type": "exotic_matter_conduit", "location": "rear_manifold" },
      { "slot_id": "gas_recovery_port", "bus_type": "pneumatic_purge_line", "location": "lateral_ring" }
    ]
  },

  "units": {},
  "metadata": {
    "version": "1.4",
    "type": "blueprint",
    "category": "infrastructure",
    "template_compliance": "unit_blueprint_v1.4"
  }
}


--------
2. Operational Data Specification (unit_operational_data_v1.3.json compliance)

{
  "id": "portal_gate_mk1_ops",
  "name": "Mk I Intra-System Portal Gate Operational Data",
  "unit_type": "facility",
  "category": "infrastructure",
  "subcategory": "transport_node",
  "description": "Operational parameters, safety telemetry, and environmental controls for Level 4a intra-system quantum portal units.",

  "processing_capabilities": {
    "atmospheric_processing": {
      "enabled": true,
      "types": ["purge_recovery", "differential_balancing"],
      "efficiency": 0.95
    },
    "geosphere_processing": { "enabled": false, "types": [], "efficiency": 1.0 },
    "resource_extraction": { "enabled": false, "types": [], "efficiency": 1.0 },
    "thermal_processing": { "enabled": true, "max_temperature_c": 120 }
  },

  "consumables": {
    "energy": 1200,
    "unit": "kilowatt_hour"
  },

  "input_resources": [
    { "material_id": "exotic_matter", "rate_kg_hr": 0.0125 },
    { "material_id": "electrical_power", "rate_kw": 1200 }
  ],
  "output_resources": [],

  "storage": { "capacity": 0, "current_level": 0 },

  "operational_status": {
    "status": "standby",
    "condition": 100.0,
    "degradation_rate": 0.001
  },

  "operational_properties": {
    "power_consumption_kw": 1200,
    "heat_generation_kw": 45,
    "failure_rate": 0.002,
    "maintenance_interval_hours": 750,

    "deployment": {
      "deployed": false,
      "current_stage": "unanchored",
      "stages": ["spine_bolting", "airlock_sealed", "em_resonance_sync", "pairing_verification"],
      "progress_percent": 0.0,
      "resource_usage": { "power_kw": 400, "materials": { "structural_sealant": 50 } },
      "time_remaining_hours": 48.0
    }
  },

  "operational_modes": {
    "current_mode": "standby",
    "available_modes": ["standby", "active_transit", "purge_cycle", "emergency_shutdown", "maintenance_lockout"]
  },

  "habitat_systems": {
    "human_accessible": true,
    "capacity": 12,
    "current_occupants": 0,
    "habitable_volume_m3": 135.0,
    "life_support_active": true,
    "pressure_kpa": 101.3,
    "thermal_regulation": {
      "target_temperature_c": 21.0,
      "current_temperature_c": 21.0,
      "humidity_percent": 42.0
    },
    "radiation_shielding": 0.85
  },

  "wellbeing_output": {
    "biophilia_rating": 1,
    "morale_contribution_per_visit": -0.05,
    "max_daily_visitors": 100,
    "sensory_richness": "utilitarian",
    "notes": "High operational white-noise; transit visual flicker."
  },

  "diagnostics": {
    "air_quality": {
      "co2_ppm": 420,
      "warning_threshold_co2": 1000,
      "critical_threshold_co2": 2000,
      "humidity_percent": 42.0,
      "warning_threshold_humidity": 70.0,
      "critical_threshold_humidity": 90.0
    },
    "temperature": {
      "celsius": 21.0,
      "warning_threshold": 35.0,
      "critical_threshold": 50.0
    },
    "radiation_level": {
      "current_msv": 0.02,
      "warning_threshold": 0.5,
      "critical_threshold": 2.0
    }
  },

  "telemetry": {
    "data_points": ["dp_dt_kpa_s", "entanglement_resonance_hz", "structural_torque_kn", "em_flow_rate_mg_s"],
    "logging_frequency_hz": 10.0
  },

  "hazards": {
    "pressure_differential": "Catastrophic blowout risk if uncoupled without vestibule isolation.",
    "magnetic_shear": "High field gradient during aperture modulation."
  },
  "required_crew": { "technician": 1, "station_operator": 1 },
  "safety_systems": [
    "emergency_bulkhead_shutoff",
    "dp_dt_trip_sensor",
    "pneumatic_gas_recovery_manifold",
    "interlock_safety_override_audit"
  ],

  "resource_requirements": {
    "construction": [
      { "material_id": "superconducting_magnets", "amount": 2500 },
      { "material_id": "carbon_nanotube_composite", "amount": 4200 },
      { "material_id": "quantum_entanglement_nodes", "amount": 4 }
    ],
    "operation": [
      { "material_id": "exotic_matter", "amount_per_hr": 0.0125 },
      { "material_id": "electrical_power", "amount_per_hr": 1200 }
    ]
  },

  "ports": {
    "internal": 2,
    "external": 2
  },

  "interfaces": ["rail_bus_v2", "structural_keel_flange", "exotic_matter_manifold"],
  "required_technologies": ["portal_technology_level_4a"],

  "metadata": {
    "version": "1.3",
    "type": "unit_operational_data",
    "category": "infrastructure",
    "template_compliance": "unit_operational_data",
    "changelog": {
      "1.3": ["Added portal-specific safety telemetry, dP/dt sensor triggers, and EM consumption loops."]
    }
  },

  "units": {},
  "template": "unit_operational_data",
  "base_cost_eap": 120000.0,
  "usd_import_fee": 5000.0
}
