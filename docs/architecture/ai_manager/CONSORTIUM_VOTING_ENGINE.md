# Consortium Voting Engine (Surgical Core File #3)

## Purpose
The Consortium Voting Engine governs all major expansion and infrastructure decisions for the AI Manager, using EM-aware, path-based ROI logic. Each major stakeholder votes based on their unique priorities, with a 66% quorum required for approval.

## EM-Path ROI Formula
```ruby
def voting_roi(system)
  path_hops = WormholeNavigator.find_shortest_path('sol', system.id)&.length || Float::INFINITY
  em_surplus = system.em_bleed_rate * refocus_efficiency_rating
  infrastructure_cost = aws_construction_cost * path_hops

  (em_surplus - infrastructure_cost) / path_hops
end
```

## Quorum Logic (66% Required)
- **LDC (30%)**: EM_surplus / artificial_wh_cost
- **AstroLift (25%)**: WormholeNavigator.hops * cycler_efficiency
- **Mars Corp (25%)**: belt_profit * path_multiplier
- **Venus Corp (15%)**: terraforming_synergy * em_funding
- **Titan Corp (5%)**: h2_siphon_capacity

## Example Voting Implementation
```ruby
def consortium_vote(system_assessment)
  votes = {
    ldc: em_roi(system_assessment),
    astrolift: path_efficiency(system_assessment),
    mars_corp: belt_extension_roi(system_assessment),
    venus_corp: terraforming_synergy(system_assessment),
    titan_corp: h2_siphon_capacity(system_assessment)
  }

  weighted_sum = votes[:ldc]*0.3 + votes[:astrolift]*0.25 + votes[:mars_corp]*0.25 + votes[:venus_corp]*0.15 + votes[:titan_corp]*0.05
  approved = weighted_sum >= 0.66
  { approved: approved, detailed_votes: votes, weighted_sum: weighted_sum }
end
```

## Integration
- This engine is Core File #3 in the [89→8_SURGICAL_MAP.md](89→8_SURGICAL_MAP.md)
- All expansion, AWS build, and major logistics decisions must pass through this voting logic
- EM windfalls and BFS distances are directly factored into every decision

---

*This file is the canonical reference for all consortium voting and ROI logic in the resurrected AI Manager.*
