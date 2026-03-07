# Task: OrbitalDepot Architecture Correction

**Priority:** MEDIUM (backlog, no current failures)  
**Agent:** GPT-4.1

## Problem
OrbitalDepot currently inherits from SpaceStation which is wrong. They are siblings not parent/child.

SpaceStation = shipyard/manufacturing hub (L1 Station)  
OrbitalDepot = logistics hub, refueling, cargo swap (LEO depot, L1 depot)

Both use Structures::Shell but serve distinct purposes. Capabilities determined by fitted Units::BaseUnit modules not class hierarchy.

## Change
app/models/settlement/orbital_depot.rb

FROM:
  class OrbitalDepot < SpaceStation

TO:
  class OrbitalDepot < BaseSettlement
    include Structures::Shell
    include Docking

## Add operational_data documentation
Document standard fitted configurations in operational_data:
- LEO depot: fuel_tanks, docking_ports, cargo_bays
- L1 depot: fuel_tanks, docking_ports, cargo_bays, fabricators (optional)

## Do NOT change
- SpaceStation (keep as-is)
- BaseSettlement (keep as-is)
- Any existing OrbitalDepot instances or seeds

## No rspec changes required unless existing depot specs break
Run after changes:
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/ -t type:model --format progress 2>&1 | tail -20'

## Commit message
"Fix OrbitalDepot inheritance - sibling of SpaceStation not subclass"