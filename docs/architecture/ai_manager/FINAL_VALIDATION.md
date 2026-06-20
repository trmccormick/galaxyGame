# Pre-Claude 5PM Validation Checklist

## RSpec (0 Failures Target)
Run the full AI Manager test suite:
```bash
docker exec -it web bash -c "unset DATABASE_URL; RAILS_ENV=test bundle exec rspec spec/services/ai_manager"
```
- **Pass Criteria:** All tests pass (0 failures)

## Smoke Tests (Core Logic)
1. **Wayfinding:**
   ```ruby
   WormholeNavigator.find_shortest_path('sol', 'eden')
   # Expected: ['sol', 'brown_dwarf', 'eden']
   ```
2. **Consortium Voting:**
   ```ruby
   consortium_vote(eden_assessment)
   # Expected: { approved: true, quorum: 0.68 }
   ```
3. **Hammer Protocol:**
   ```ruby
   hammer_protocol.execute()
   # Expected: mass_limit_exceeded
   ```

## Final Verification
- [ ] 8 core files present, 81 bloat files removed
- [ ] All orchestration matches [AI_MANAGER_ARCHITECTURE.md](AI_MANAGER_ARCHITECTURE.md)
- [ ] Voting logic matches [CONSORTIUM_VOTING_ENGINE.md](CONSORTIUM_VOTING_ENGINE.md)
- [ ] All supporting docs up to date
- [ ] Ready for Claude 5PM handoff

---

*Complete this checklist for a flawless 89→8 deployment and galactic AI Manager launch.*
