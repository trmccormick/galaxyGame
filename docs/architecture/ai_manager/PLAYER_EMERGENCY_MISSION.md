## Player Emergency Missions

When AI Manager cannot procure critical resources through normal channels, it creates **Special Missions** for players:

### Trigger Conditions:
- Normal procurement failed (no suppliers found)
- Resource is survival-critical (O₂, H₂O, Food)
- Settlement has sufficient GCC for rewards

### Mission Properties:
- **Base Reward:** Earth Anchor Price × quantity × 1.5
- **Bonus Multiplier:** 2.0x for critical urgency
- **Expiration:** 24 hours
- **Priority:** Displayed prominently to all players

### Example:
```
URGENT: Oxygen Crisis at Mars Base Alpha
- Material: Oxygen
- Quantity: 500 kg
- Reward: 150,000 GCC (2x bonus for urgency!)
- Expires: 23 hours
- Status: CRITICAL - Settlement life support failing
```

This creates high-value opportunities for players during NPC emergencies.