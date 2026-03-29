# Intent: L1 Depot (Station Shell)

## 1. Core Identity
The L1 Depot is a **Settlement Namespace** that acts as a structural shell. It provides no inherent processing, refining, or life support capabilities on its own.

## 2. Infrastructure as a Service
- **Inventory System**: Uses the standard `Settlement::Inventory` logic to track bulk gases and components.
- **Unit Slots**: Provides "Hardpoints" for the installation of permanent units (Refinery Modules, Power Cores).
- **Docking Ports**: Provides "Soft-links" for transient units (Skimmers, Cyclers).

## 3. Operational Logic
- **Passive State**: Without installed units, the Depot is a cold storage vault.
- **Active State**: The Depot's capabilities (Refinery throughput, Power levels) are the sum of its **Installed Units** + **Attached Units**.