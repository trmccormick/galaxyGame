# Task A: Dome/Settlement Cleanup (3 failures → 0)

**Priority:** HIGH  
**Agent:** GPT-4.1 Copilot (Agent mode)  
**Impact:** Removes 3 dome_spec.rb failures

## Current Status
- ~206-209 failures post-storage cleanup (commit dacfe665)
- spec/models/dome_spec.rb: 3 failures (capacity, remaining_capacity, occupancy guard)
- Need to determine: live concept OR dead legacy (like Storage POROs)?

## Your Tasks
1. **Investigate Dome status:**
   grep -r "Dome|Settlement::Dome" app/ spec/ --exclude-dir=storage

2. **Two paths based on grep results:**

   **Path A - Dead code (likely):**
   rm app/models/settlement/dome.rb # if exists
   rm spec/models/dome_spec.rb
   git commit -m "refactor: remove obsolete Dome model/spec (legacy)"

   **Path B - Live concept:**
   - Review `dome_spec.rb` expectations
   - Align `app/models/settlement/dome.rb` with spec OR update spec for current model
   - Run `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/dome_spec.rb --format documentation'`

3. **Report:**
   - Grep results (Dome refs found?)
   - Path taken (A or B)
   - New failure count
   - git log --oneline -3

## Expected Outcome
Another ~3 failures gone, total ~203-206

**Time Estimate:** 25 minutes