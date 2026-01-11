## AI Priority System

The AI Manager uses a heuristic-based priority system for operational decisions:

### Critical Priorities (Immediate Action):
1. **Life Support** - Oxygen/water/food refill
2. **Atmospheric Maintenance** - Gas level monitoring
3. **Debt Repayment** - Financial stability

### Operational Priorities (Scheduled):
4. **Resource Procurement** - Material shortages
5. **Construction** - Storage modules, infrastructure
6. **Expansion** - Growth when stable

### Decision Flow:
```
Check critical priorities → Handle immediately if found
↓ (if none)
Assess settlement state → Life support → Resources → Expansion
↓
Execute appropriate handler → Planner/Builder/Fulfillment Service
```

This ensures survival-critical tasks always take precedence over growth.