# Covering System: structure_type Validation Fix
Date: 2026-03-25
Priority: HIGH (regression from 7a73ea78)
Estimated: 30-45 minutes
Cluster: Covering System (3 specs)
Specs: spec/integration/covering_system_integration_spec.rb [43,155,176]

## Problem
Worldhouse.create! fails validation "Structure type can't be blank" despite operational_data["structure_type"] = "worldhouse".

## Root Cause
- BaseStructure validates :structure_type, presence: true (DB column)
- Worldhouse (specialized structure: large-scale geological enclosure) missing callback
- Precedent: CraterDome sets self.structure_type AND operational_data
- SpaceStation likely follows same pattern

## Design Intent
- Worldhouse inherits BaseStructure (like SpaceStation, CraterDome)
- structure_type = direct DB column + operational_data mirror
- Subclasses provide set_structure_type callback

## Diagnostics (Run These First)
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/covering_system_integration_spec.rb --format doc"
grep -n "structure_type\|before_validation" app/models/structures/worldhouse.rb app/models/structures/base_structure.rb
grep -n "set_structure_type" app/models/structures/ app/models/settlement/space_station.rb
