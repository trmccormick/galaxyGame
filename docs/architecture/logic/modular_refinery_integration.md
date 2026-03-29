# Logic: Modular Refinery & Skimmer Integration

## 1. The Processing Multiplier
To reflect the "Skimmer-as-Booster" intent, the `Settlement::ProcessingService` must calculate throughput dynamically.

**Logic Pattern:**
`Total Throughput = Base_Depot_Capacity + (Sum(Docked_Skimmer_Capacity) * Efficiency_Modifier)`

- **Base_Depot_Capacity**: Constant defined by the L1 Depot's installed refinery modules.
- **Efficiency_Modifier**: 1.15x (15% boost) per docked skimmer, representing the integration of the skimmer's specialized processors into the Depot's main bus.

## 2. Handover & Redundancy Logic
In the event of a `Depot_Overload` or `Refinery_Failure`:
1. **Interrupt Task**: Current processing jobs are paused.
2. **Re-route**: Incoming Skimmers receive a `Vector_Change` packet to Luna Surface.
3. **State Change**: Skimmers at the Depot transition from `Processing_Slave` mode to `Standby_Storage` mode to conserve Depot power.

## 3. RSpec Verification Criteria
For the `refinery_service_spec.rb` to pass:
- **Test A**: Verify that adding a `Venus_Skimmer` to a `L1_Depot` increases the `lox_production_rate`.
- **Test B**: Verify that a `Titan_Skimmer` docked at the Depot can independently fractionate methane if the Depot’s primary processor is occupied with CO2.