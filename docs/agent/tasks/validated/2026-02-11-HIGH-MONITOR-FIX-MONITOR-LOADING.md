# Fix Monitor Loading (0x Task)

**Target**: app/services/monitor/monitor_loading_service.rb

**Issue**: Monitor loading service fails under certain conditions, causing incomplete or delayed monitoring data.

**Diagnostic**:
```bash
grep -n 'monitor_loading' app/services/monitor/
unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/monitor/monitor_loading_service_spec.rb -v
```

**Tasks**:
1. Synthesis Report (current state analysis) → STOP
2. Debug and fix monitor loading logic
3. RSpec: expect(service.load_status).to eq('complete')
4. Commit: "fix: monitor loading service reliability"

Priority: HIGH | 45min
