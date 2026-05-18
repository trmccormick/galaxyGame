# 2026-04-17-HIGH-MACRO-WORMHOLE-STABILITY-MONITOR

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — High priority macro feature for wormhole stability monitor
**Supervision Level**: 🔴 Watched carefully

## Context
Star systems maintain data networks with stations/bases as nodes relaying information. Manifest/relay-based architecture monitors network health. Issues with data integrity, staleness, spoofing occur at transfer points.

## Problem Statement
No manifest/relay-based wormhole stability monitoring implemented. No taint propagation, spoofing detection, ACK confirmation logic.

**Expected**: Manifest/relay-based monitoring integrated with station operational profiles, triggering stabilization protocols and mission generation on instability/taint events.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/models/manifest.rb` | Manifest model | Implement hash-chained integrity, versioning, taint propagation |
| `app/models/ack_receipt.rb` | ACK model | Implement receipt logic |
| `app/services/manifest_verifier.rb` | Verification service | Create chain validation, spoofing detection |
| `app/services/wormhole_stability_monitor.rb` | Monitor service | Integrate health checks and stabilization triggers |
| `app/models/aws_station.rb` | Station model | Add relay logic |
| `app/models/base_craft.rb` | Craft model | Add manifest handling |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `docs/planning/courier_network_plan.md` | Canonical requirements |
| `docs/planning/GEMINI-CHAT.md` | Network planning |
| `docs/planning/RESTORATION_AND_ENHANCEMENT_PLAN.md` | Enhancement plan |

## Implementation Steps
1. **Manifest model**: Hash-chained integrity, versioning, taint propagation fields
2. **Station relay**: Broadcast and ACK logic in AWS/NWA operational profiles
3. **ManifestVerifier**: Chain validation, spoofing detection, taint propagation
4. **Stability monitor**: Manifest/relay health checks and stabilization triggers
5. **Mission generation**: Trigger auditor/stabilization missions on taint/instability
6. **RSpec**: Full test coverage for all logic and edge cases

## Acceptance Criteria
- [ ] Manifest model implements hash-chained integrity, versioning, taint propagation
- [ ] Station relay logic broadcasts manifests and validates ACKs
- [ ] ManifestVerifier validates chains, detects spoofing, triggers taint propagation
- [ ] Emergency stabilization protocols and mission triggers on instability/taint
- [ ] RSpec coverage for all core logic and edge cases

## Stop Conditions
- Duplicate or obsolete wormhole monitoring logic exists outside manifest/relay system

## Commit Instructions
```bash
git add app/models/manifest.rb
git add app/models/ack_receipt.rb
git add app/services/manifest_verifier.rb
git add app/services/wormhole_stability_monitor.rb
git add app/models/aws_station.rb
git add app/models/base_craft.rb
git add spec/services/wormhole_stability_monitor_spec.rb
git add spec/services/manifest_verifier_spec.rb
git commit -m "feat: wormhole stability monitor — implement manifest/relay-based network health monitoring"
```