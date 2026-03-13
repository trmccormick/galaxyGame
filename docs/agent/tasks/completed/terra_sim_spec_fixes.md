# Task: Fix TerraSim Cluster — 5 Failures Across 3 Specs

## Overview
Three distinct fixes. Two are spec-only, one requires a small service change.
Do NOT add database migrations — the regolith columns don't exist yet by design.

---

## Fix 1: `ice_tectonic_enabled` is private (failures at geosphere_initializer_spec:88, geosphere_simulation_service_spec:50)

### Problem
`Geosphere` has two methods:
- `ice_tectonics_enabled?` — PUBLIC
- `ice_tectonic_enabled` — PRIVATE (no `?`)

The service `geosphere_simulation_service.rb` and the spec both call the private
version `ice_tectonic_enabled` instead of the public `ice_tectonics_enabled?`.

### Files to modify
1. `app/services/terra_sim/geosphere_simulation_service.rb`
2. `spec/services/terra_sim/geosphere_initializer_spec.rb`

### Fix service — find:
```ruby
if @geosphere.ice_tectonic_enabled
```
Replace with:
```ruby
if @geosphere.ice_tectonics_enabled?
```

### Fix spec — find (around line 90):
```ruby
expect(ice_giant.geosphere.ice_tectonic_enabled).to be true
```
Replace with:
```ruby
expect(ice_giant.geosphere.ice_tectonics_enabled?).to be true
```

### Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/terra_sim/geosphere_initializer_spec.rb:88 spec/services/terra_sim/geosphere_simulation_service_spec.rb:50 --format progress 2>&1 | tail -3'
```
Expected: 2 examples, 0 failures

---

## Fix 2: Regolith spec `before` block crashes before `skip` runs (failures at geosphere_initializer_spec:157, 173)

### Problem
The `it` blocks correctly skip with `skip "Regolith columns don't exist yet" unless column_exists?(:geospheres, :regolith_depth)`.
BUT the `before` block runs FIRST and tries to stub `determine_regolith_depth` and
`determine_particle_size` which don't exist on `GeosphereInitializer`, causing failure
before the skip is ever reached.

### File to modify
`spec/services/terra_sim/geosphere_initializer_spec.rb`

### Find the before block (around line 148):
```ruby
before do
  # Create atmosphere for the Earth-like body
  earth_atmosphere
  
  # Set body types directly
  allow_any_instance_of(TerraSim::GeosphereInitializer).to receive(:determine_regolith_depth).and_return(3.0)
  allow_any_instance_of(TerraSim::GeosphereInitializer).to receive(:determine_particle_size).and_return(0.5)
end
```

### Replace with:
```ruby
before do
  # Create atmosphere for the Earth-like body
  earth_atmosphere
  
  # Only stub regolith methods if the columns exist
  if ActiveRecord::Base.connection.column_exists?(:geospheres, :regolith_depth)
    allow_any_instance_of(TerraSim::GeosphereInitializer).to receive(:determine_regolith_depth).and_return(3.0)
    allow_any_instance_of(TerraSim::GeosphereInitializer).to receive(:determine_particle_size).and_return(0.5)
  end
end
```

### Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/terra_sim/geosphere_initializer_spec.rb:157 spec/services/terra_sim/geosphere_initializer_spec.rb:173 --format progress 2>&1 | tail -3'
```
Expected: 2 examples, 0 failures (they will show as pending/skipped, not failed)

---

## Fix 3: `update_temperatures` doesn't clamp values before passing to atmosphere (failure at atmosphere_simulation_service_spec:126)

### Problem
The spec sets `@base_temp = 500.0` (above max 400) and expects the service to
clamp it before calling `atmosphere.set_effective_temp`. But the service passes
the raw unclamped value directly.

### File to modify
`app/services/terra_sim/atmosphere_simulation_service.rb`

### Find `update_temperatures` method (around line 88):
```ruby
def update_temperatures
  atmosphere = @celestial_body.atmosphere
  return unless atmosphere
  
  # Update the various temperature types using our new methods
  atmosphere.set_effective_temp(@base_temp)
  atmosphere.set_greenhouse_temp(@surface_temp)
  atmosphere.set_polar_temp(@polar_temp)
  atmosphere.set_tropic_temp(@tropic_temp)
  
  # Also update the celestial body's surface temperature
```

### Replace with:
```ruby
def update_temperatures
  atmosphere = @celestial_body.atmosphere
  return unless atmosphere

  # Clamp temperatures to valid ranges before updating
  clamped_base_temp    = @base_temp.clamp(150.0, 400.0)
  clamped_surface_temp = @surface_temp.clamp(150.0, 400.0)
  clamped_polar_temp   = @polar_temp.clamp(100.0, 350.0)
  clamped_tropic_temp  = @tropic_temp.clamp(150.0, 400.0)

  # Update the various temperature types using clamped values
  atmosphere.set_effective_temp(clamped_base_temp)
  atmosphere.set_greenhouse_temp(clamped_surface_temp)
  atmosphere.set_polar_temp(clamped_polar_temp)
  atmosphere.set_tropic_temp(clamped_tropic_temp)

  # Also update the celestial body's surface temperature
```

NOTE: Continue the rest of the method unchanged after this point. Only replace
up to and including the `set_tropic_temp` call and the comment after it.

### Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/terra_sim/atmosphere_simulation_service_spec.rb:126 --format progress 2>&1 | tail -3'
```
Expected: 1 example, 0 failures

---

## Final Verification

Run the full terra_sim suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/terra_sim/ --format progress 2>&1 | tail -3'
```
Expected: 123 examples, 0 failures, 3 pending (the regolith skips count as pending)
