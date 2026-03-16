# Task: Rewrite PlanetaryGeologicalFeatureLookupService Spec to Use Real Data

## Assignee: GPT-4.1
## Priority: Medium (test pollution fix — causes ~16 failures in full suite)
## Branch: regional-view-phase2

---

## Problem

`spec/services/lookup/planetary_geological_feature_lookup_service_spec.rb`
currently stubs `GalaxyGame::Paths::JSON_DATA` to a temp directory and creates
synthetic fixture files. This causes test pollution in the full suite — the
`stub_const` interacts badly with other specs that also reference `JSON_DATA`,
causing the spec to receive a stale/wrong path and load zero features.

The spec passes in isolation but produces ~16 failures in the full suite run.

The root cause: this is the only lookup spec that uses `stub_const` on
`JSON_DATA`. The other lookup specs (`material_lookup_service_spec`,
`unit_lookup_service_spec`) use real data files throughout and have no
pollution issues. This spec must follow the same pattern.

---

## Solution

Rewrite the spec to use real geological feature data files that already exist
on disk, removing all temp dir infrastructure entirely.

**Real data available at:**
```
data/star_systems/sol/celestial_bodies/earth/luna/geological_features/
  craters.json
  craters_catalog.json
  lava_tubes.json
```

**Reference pattern to follow:** `unit_lookup_service_spec.rb` — uses
`GalaxyGame::Paths` constants directly, no stubs, no temp dirs, no fixture
helpers.

---

## Instructions

### Step 1 — Remove all temp dir infrastructure

Delete the following entirely from the spec:

- `let(:temp_test_dir) { Dir.mktmpdir(...) }`
- `before { stub_const('GalaxyGame::Paths::JSON_DATA', temp_test_dir) }`
- `after { FileUtils.rm_rf(temp_test_dir) if File.exist?(temp_test_dir) }`
- `def create_test_feature_file`
- `def create_invalid_json_file`
- `def build_fixture_path`

Do NOT use `stub_const` anywhere in the rewritten spec.

### Step 2 — Replace celestial body setup with Luna

The service requires a real celestial body whose geological features directory
actually exists on disk. Luna is the correct choice.

Replace the `earth` and `mars` factory setup with a Luna instance. Luna is a
moon, so it requires a `parent_celestial_body` (Earth) for `body_feature_path`
to resolve correctly to:

```
star_systems/sol/celestial_bodies/earth/luna/geological_features
```

The factory chain should look approximately like:
```ruby
let(:star)  { create(:star) }
let(:sol)   { create(:solar_system, current_star: star, name: 'Sol') }
let(:earth) { create(:terrestrial_planet, :earth, solar_system: sol) }
let(:luna)  { create(:moon, name: 'Luna', parent_celestial_body: earth,
                     solar_system: sol) }
```

Adjust factory names to match what actually exists in the project. The
critical requirement is that `luna.solar_system.name` returns `'Sol'`,
`luna.parent_celestial_body.name` returns `'Earth'`, and `luna.name` returns
`'Luna'` — these three values drive the path resolution in `body_feature_path`.

### Step 3 — Rewrite tests against real data

Assert against real content from Luna's JSON files. Before writing the spec,
read the actual JSON files to confirm feature names, types, and structure:

```bash
cat data/star_systems/sol/celestial_bodies/earth/luna/geological_features/craters.json
cat data/star_systems/sol/celestial_bodies/earth/luna/geological_features/lava_tubes.json
```

Then rewrite the tests to use real values. For example:
- `all_features` — assert `not_to be_empty` and count is > 0
- `find_by_name` — use a real feature name from the JSON
- `features_by_type` — use a real feature type present in the data
- `feature_summary` — assert real type keys are present

Do not hardcode counts or names that could change if data files are updated —
prefer `not_to be_empty`, `be > 0`, and `include` matchers over exact equality
where reasonable.

### Step 4 — Handle the "no data" case

The previous spec used `mars` to test the empty/missing case. Replace this
with a celestial body that genuinely has no geological features directory.

The cleanest approach is a simple double:
```ruby
let(:unknown_body) do
  instance_double('CelestialBodies::CelestialBody',
    name: 'Unknown',
    solar_system: instance_double('SolarSystem', name: 'Unknown'),
    parent_celestial_body: nil
  )
end
```

This will resolve to a path that doesn't exist, triggering the
`return [] unless feature_path.exist?` guard in the service — which is the
correct behavior to test.

### Step 5 — Fix error handling tests

The corrupted JSON and missing directory tests must not use `stub_const`.
Rewrite them as follows:

- **Missing directory** — use the `unknown_body` double above, which naturally
  resolves to a non-existent path. No stubbing needed.
- **Corrupted JSON** — use a targeted `allow` stub on the service instance's
  private `load_features` or test by passing a real temp dir directly to
  `load_json_files` if that method is accessible. Do NOT stub `JSON_DATA`.
- **Logger debug test** — simply initialize the service with `luna` and assert
  the debug log fires. Allow other debug messages via `allow(Rails.logger).to
  receive(:debug)` before the specific expectation.

### Step 6 — Fix path construction test

Update the path assertion to reflect Luna's actual path:
```ruby
it 'constructs correct path for moon' do
  service = described_class.new(luna)
  actual_path = service.send(:body_feature_path)
  expect(actual_path.to_s).to end_with(
    'star_systems/sol/celestial_bodies/earth/luna/geological_features'
  )
end
```

---

## Do NOT

- Use `stub_const` anywhere in this spec
- Create `Dir.mktmpdir` temp directories
- Change the service implementation file
  (`app/services/lookup/planetary_geological_feature_lookup_service.rb`)
- Use the `earth` or `mars` factory as the primary celestial body (neither has
  geological feature files on disk)
- Hardcode exact feature counts that could break if data files are updated

---

## Escalation Rule

If the Luna factory chain does not resolve `body_feature_path` to the correct
path on the first attempt, **stop and escalate to Claude** before making
further patch attempts. Do not guess at factory trait names.

---

## Verify

Run in isolation first:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/lookup/planetary_geological_feature_lookup_service_spec.rb > ./log/rspec_full_$(date +%s).log 2>&1'
```

Then confirm it passes as part of the full lookup directory (pollution check):
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/lookup/ > ./log/rspec_full_$(date +%s).log 2>&1'
```

Both runs must be green before this task is complete.
