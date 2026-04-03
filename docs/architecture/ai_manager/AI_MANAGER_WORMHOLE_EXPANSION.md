# AI Manager Wormhole Network Expansion (Refinement)

## Strategic Objective
Enable the AI Manager to autonomously expand into new star systems via wormhole (WH) events, dynamically deciding between resource harvesting ("hammer"), infrastructure buildout (AWS/depots), and network expansion based on system conditions and economic priorities.

---

## Expansion Task Flow
1. **Wormhole Detection**
   - Monitor for new WH events (system exits, procedural discoveries)
   - Trigger expansion protocol when a new system is accessible

2. **System Assessment**
   - Scan for resource abundance (PGMs, volatiles, water, energy)
   - Evaluate habitability, terraforming potential, and economic ROI
   - Identify threats (hostile environment, instability, competition)

3. **Expansion Decision Matrix**
   | Condition                | Action                | Priority |
   |--------------------------|-----------------------|----------|
   | High-value resources     | Harvest/Hammer        | High     |
   | Terraforming potential   | AWS/Depot Buildout    | High     |
   | Hostile/unstable system  | Minimal outpost/Probe | Medium   |
   | Strategic location       | Network Node (Relay)  | High     |
   | Low ROI                  | Monitor only          | Low      |

4. **Action Selection**
   - If resources > threshold: Deploy harvesters, mining fleets ("hammer")
   - If terraforming score > threshold: Build AWS, depots, and support infrastructure
   - If system is a network chokepoint: Prioritize relay node construction
   - If hostile: Send probes, establish minimal outpost, monitor

5. **Network Integration**
   - Connect new system to existing logistics network (cyclers, depots, JSON mission profiles)
   - Update mission priorities and fleet allocation
   - Rebalance resource flows and economic models

---

## AI Manager Expansion Logic (Ruby)
```ruby
def expand_wormhole_network
  if wormhole_detected?
    new_system = scan_new_system
    case assess_system(new_system)
    when :high_resource
      deploy_harvesters(new_system)
    when :terraforming_candidate
      build_aws_and_depots(new_system)
    when :strategic_node
      construct_network_relay(new_system)
    when :hostile
      send_probe_and_monitor(new_system)
    else
      log("No immediate action for #{new_system}")
    end
    integrate_into_network(new_system)
    update_mission_profiles
  end
end
```

---

## Expansion Criteria (JSON Example)
```json
{
  "expansion_targets": [
    { "system": "PROC-X47B", "resource_score": 8.5, "terraform_score": 2.1, "action": "harvest" },
    { "system": "EDEN", "resource_score": 4.2, "terraform_score": 9.8, "action": "aws_buildout" },
    { "system": "JUPITER_RELAY", "resource_score": 3.0, "strategic": true, "action": "network_node" }
  ]
}
```

---

## Summary
- AI Manager autonomously expands into new systems via WH events
- Dynamically chooses between harvesting, AWS/buildout, or network relay based on system assessment
- Integrates new systems into the logistics and economic network
- All decisions are data-driven, state-agnostic, and update JSON mission profiles

---

**Next Steps:**
- Implement expansion protocol in orchestration layer
- Validate with test WH events and system profiles
- Integrate with mission prioritization and fleet dispatch logic
