# Add Admin Celestial Body Show View (0x Task)

**Target**: app/views/admin/celestial_bodies/show.html.erb

**Issue**: Missing or incomplete admin show view for celestial bodies, limiting admin visibility and management.

**Diagnostic**:
```bash
grep -n 'celestial_body' app/views/admin/celestial_bodies/
```

**Tasks**:
1. Synthesis Report (current state analysis) → STOP
2. Design and implement show view for celestial bodies
3. RSpec: expect(page).to have_content('Celestial Body')
4. Commit: "feat: add admin celestial body show view"

Priority: HIGH | 45min
