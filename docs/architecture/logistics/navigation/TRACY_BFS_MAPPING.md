# TRACY_BFS_MAPPING.md

## File Manifest

- **Service:** `app/services/navigation/wormhole_navigator.rb` (BFS pathfinding logic)
- **Model Extension:** `app/models/solar_system.rb` (API for system-to-system navigation)
- **Data Schema:** `wormhole_contract.json` (Constants, Mass Limits, link_registry)

---

## Validation

The WormholeNavigator must check the `link_registry` in the JSON data to ensure that, if the link is an artificial portal, the ship's mass does not exceed `portal_max_mass`. If the mass is too high, the edge is skipped during pathfinding.

---

See also: legacy_tracy_bfs_pathfinding.md for implementation details and requirements.
