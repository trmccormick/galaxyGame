# Intent: Mission Manifests & Unit Seeding

## Manifest Structure
The `mission_manifest` defines the initial state of a deployment.
* **Active Units**: Found in `craft.installed_units`. These have immediate operational requirements (fuel, power, port connections).
* **Crated Units**: Found in `inventory.units`. These are dormant items waiting for the `UnpackingService`.

## The Robot Unpacking Protocol
When transitioning a robot from a manifest inventory to an active state:
1. **Blueprint Sync**: Attributes must be merged from the `data/json-data/blueprints/units/robots/` directory.
2. **Port Awareness**: Unlike the craft's internal modules, robots are created as independent `BaseUnit` instances attached to the `Settlement`, not a specific port.
3. **Identifier Generation**: The `identifier` is generated at the moment of unpacking, not during manifest creation.