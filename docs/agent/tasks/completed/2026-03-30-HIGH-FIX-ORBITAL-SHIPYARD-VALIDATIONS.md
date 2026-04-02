TASK: OrbitalShipyardService.create_shipyard_project validation failures (7 specs)
Status: ACTIVE
Priority: HIGH
Type: bug-fix
Created: 2026-03-30
Last Updated: 2026-03-30

Agent Assignment
Assigned To: GPT-4.1 0x
Why This Agent: 7 sequential failures same method, factory/service init pattern, fully specified diagnostics
Supervision Level: 🔴 Watched carefully

Context
OrbitalShipyardService manages orbital construction projects for shipyards. create_shipyard_project fails 7 validation specs (lines 11,17,22,27,32,37,43) testing associations, blueprint_id, status, progress, and materials initialization. Likely factory missing required context or service expects specific initialization.

Relevant Architecture Docs:

docs/architecture/manufacturing.md — blueprint/materials initialization patterns

docs/developer/practical_testing_guide.md — service spec factory patterns

Problem Statement
All 7 create_shipyard_project specs fail on validation/attribute setting.

Error output (expected pattern):

text
ActiveRecord::RecordInvalid: Validation failed: [various association/blueprint/status errors]
Current behavior: Project creation fails validation
Expected behavior: Creates valid project with all associations, blueprint materials, correct initial state

Files Involved
Primary Files — you will edit these
File	Purpose	Key Method/Section
app/services/construction/orbital_shipyard_service.rb	Project creation logic	#create_shipyard_project
spec/services/construction/orbital_shipyard_service_spec.rb	Failing validations	lines 11,17,22,27,32,37,43
Reference Files — read but do not edit
File	Why You Need It
spec/factories/blueprints.rb	Blueprint factory structure
spec/factories/settlements.rb	Station/settlement factory context
app/models/project.rb	Project validations/associations
Migration (if needed)
No migration needed

Implementation Steps
Step 1 — Diagnostics (run ALL exactly)
bash
docker exec -it web bash -c 'grep -n "create_shipyard_project\\|blueprint_id\\|station\\|materials" app/services/construction/orbital_shipyard_service.rb'
docker exec -it web bash -c 'grep -A20 -B5 "11\\|17\\|22\\|27\\|32\\|37\\|43" spec/services/construction/orbital_shipyard_service_spec.rb'
docker exec -it web bash -c 'grep -n "station\\|settlement\\|blueprint" spec/factories/'
docker exec -it web bash -c 'grep -n "validate\\|validates\\|belongs_to" app/models/project.rb 2>/dev/null || echo "No project model validations found"'
Step 2 — Produce Synthesis Report and STOP
Step 3 — Likely Fix Patterns (one or more needed)
Pattern A: Service needs settlement context

ruby
# BEFORE
def create_shipyard_project(params)
  # missing @settlement context
end

# AFTER
def create_shipyard_project(settlement, params)
  @settlement = settlement
  project = Project.new(params.merge(station: settlement.space_station, blueprint_id: params[:blueprint_id]))
  # ...
end
Pattern B: Factory missing associations

ruby
# spec/factories/ - ADD to blueprint/settlement factories
factory :orbital_shipyard_project, class: 'Project' do
  station { create(:space_station).space_station }
  blueprint { create(:blueprint, :shipyard) }
  status { 'materials_pending' }
  progress_percentage { 0 }
end
Pattern C: Service materials initialization

ruby
# Add to create_shipyard_project
project.delivered_materials = blueprint.materials.each_with_object({}) { |m, h| h[m.material_type] = 0 }
Synthesis Report Format
text
THE FAILURE
Specs: orbital_shipyard_service_spec.rb:[11,17,22,27,32,37,43]
Errors: [paste exact validation errors]

ROOT CAUSE
[factory missing X, service missing Y context, etc]

PROPOSED FIX
[exact code changes needed]

FILES TO CHANGE
1. [file.rb] — [what/why]
2. [file.rb] — [what/why]

RISK
[shared factory/service impact]

READY TO APPLY? — waiting for approval
Testing Sequence
Isolation:

bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/construction/orbital_shipyard_service_spec.rb'
Construction services:

bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/construction/'
Models verification:

bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/project_spec.rb 2>/dev/null || echo "no project spec"'
Acceptance Criteria
Isolation spec: 0 failures (was 7)

Construction services: no new failures

Project creates with blueprint_id, station association, materials initialized

status: 'materials_pending', progress_percentage: 0

Stop Conditions
Factory changes affect other construction specs

Project model validations changed unexpectedly

Service requires database migration

Blueprint association missing from model

Commit Instructions
bash
git add app/services/construction/orbital_shipyard_service.rb
git add spec/services/construction/orbital_shipyard_service_spec.rb  # if spec changes
git add spec/factories/  # if factory changes
git commit -m "fix: OrbitalShipyardService.create_shipyard_project — validation fixes"
git push
Documentation
No doc changes needed

Dependencies
Blocked by: none
Blocks: none
Related tasks: none

Completion Report
Filled by implementing agent

