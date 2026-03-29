# Survey & Handshake Protocol (AWS Reconnection)

## 1. Phase I: The Seismic Survey (Pre-Construction)
Before the AI Manager authorizes a `Tug` mission to move an asteroid, a **Scout Class** ship must perform a "Seismic Survey" to generate a `StructuralProfile`.

### 1.1 Qualification Data
The survey must confirm the asteroid is not a "Rubble Pile" by verifying:
* **Core Density:** Must be > 1.5 g/cm³.
* **Volatile Pockets:** Must be < 10% for high-heat AWS suitability.
* **Result:** This survey data is required as an input for the `AIManager::StationCostBenefitAnalyzer`.

## 2. Phase II: The Handshake Token (The Physical Key)
Once the AWS Anchor (Asteroid Conversion) is 100% complete in the orphaned system (Eden), it generates a **Handshake Token**.

### 2.1 Physical Data Vault
* **Mechanism:** The token is stored in a `PhysicalDataVault` object.
* **Data Payload:** Contains the precise `SpatialLocation` (x, y, z) and `GravitationalVariance` of the Eden Anchor.
* **Security:** This data cannot be transmitted via long-range comms due to the "Snap" interference. It **must** be physically carried by a Scout or Data Courier back to Sol.

## 3. Phase III: Targeted Injection (The Activation)
The Sol-side AWS cannot fire until the `HandshakeToken` is delivered to a Sol-side WTC Station.
* **Validation:** The `Wormhole::InjectionService` consumes the token to "lock" the coordinates.
* **Execution:** Upon consumption, the service creates the `Wormhole` record linking Sol and Eden, bypassing the standard random generation logic.