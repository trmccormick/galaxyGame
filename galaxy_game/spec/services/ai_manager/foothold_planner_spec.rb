# spec/services/ai_manager/foothold_planner_spec.rb
#
# =============================================================================
# TEST CASE: Super-Mars (No Moons) — resource-first foothold planning
# =============================================================================
# This is a TEST CASE / DESIGN PROBE, not a full Super-Mars world implementation.
#
# Scenario: a larger, closer-orbit Mars-type planet in a system with
#   - NO moons
#   - NO Earth/Venus analogs (no nearby import nodes)
#   - nearby small asteroids (Phobos/Deimos-class, within the planner's
#     accessible mass window)
#
# Expected reasoning class (the point of the test):
#   The planner must INVENT an asteroid-capture → depot-bootstrap path instead
#   of matching a named "luna-first" or "mars-standard" pattern. Concretely:
#     1. `captured_asteroid` is present in the ranked options (invented path)
#     2. `captured_asteroid` ranks ABOVE `orbital_depot` (which has no moons
#        to leverage — the "luna-first" path is dead in this system)
#     3. `captured_asteroid` carries the capture → hollow → convert task
#        sequence and a high-local bias
#
# See: docs/architecture/ai_manager/SUPER_MARS_NO_MOON_TEST_CASE.md
#      docs/architecture/ai_manager/FOOTHOLD_PLANNER_ARCHITECTURE.md
# =============================================================================
require 'rails_helper'
# Load the AIManager module + PrecursorCapabilityService (dependency), then the
# class under test. FootholdPlanner is not yet listed in app/services/ai_manager.rb,
# so it is required directly here.
require_relative '../../../app/services/ai_manager'
require_relative '../../../app/services/ai_manager/foothold_planner'

RSpec.describe AIManager::FootholdPlanner do
  # --- Scenario body: a Mars-like solid planet (thin CO2 atmosphere, regolith) ---
  # `terrestrial_planet` → TerrestrialPlanet → SolidBodyConcern → has_solid_surface? == true
  let(:super_mars) { create(:terrestrial_planet, :mars) }

  # --- System topology: NO moons, NO nearby import nodes, small asteroids present ---
  # Asteroid masses are chosen inside the planner's accessible window
  # (100 kg < mass < 1e12 kg) so the `captured_asteroid` path is viable.
  let(:nearby_asteroids) do
    [
      { mass: 1.0e10, composition: %w[H2O Fe Ni], accessibility: :nearby },
      { mass: 5.0e9,  composition: %w[CO2 H2O],   accessibility: :nearby }
    ]
  end

  let(:no_moon_context) do
    {
      moons: [],                 # <-- the defining property of this scenario
      asteroids: nearby_asteroids,
      distance_from_sun: 1.2,    # closer-orbit than Mars
      parent_body: nil,
      nearby_nodes: []           # <-- no Earth/Venus analogs to import from
    }
  end

  let(:planner) { described_class.new(super_mars, system_context: no_moon_context) }
  let(:options) { planner.plan }
  let(:patterns) { options.map(&:pattern) }

  describe 'Super-Mars no-moon scenario (resource-first foothold planning)' do
    it 'is a test case for resource-first planning, not a named-pattern match' do
      # The planner is driven by the body + system snapshot, not a pattern_name.
      expect(planner).to respond_to(:plan)
      expect(options).to be_an(Array)
      expect(options).not_to be_empty
    end

    it 'invents the captured_asteroid path (no pre-written pattern fits cleanly)' do
      expect(patterns).to include(:captured_asteroid)
    end

    it 'ranks captured_asteroid ABOVE orbital_depot (the luna-first path is dead with no moons)' do
      expect(patterns).to include(:orbital_depot)

      captured_idx = patterns.index(:captured_asteroid)
      orbital_idx  = patterns.index(:orbital_depot)

      expect(captured_idx).to be < orbital_idx,
        "Expected captured_asteroid (#{captured_idx}) to rank above orbital_depot (#{orbital_idx}) " \
        "in a no-moon system"
    end

    it 'gives captured_asteroid a high-local bias (bootstrap from local/near-body resources)' do
      captured = options.find { |o| o.pattern == :captured_asteroid }
      expect(captured.local_vs_import_bias).to eq(:high_local)
    end

    it 'sequences captured_asteroid as survey → capture → hollow → depot conversion' do
      captured = options.find { |o| o.pattern == :captured_asteroid }
      phases = captured.task_sequence.map { |step| step[:phase] }

      expect(phases).to include('asteroid_survey')
      expect(phases).to include('capture_operation')
      expect(phases).to include('hollowing')
      expect(phases).to include('depot_conversion')

      # Ordering: survey before capture before hollowing before conversion
      expect(phases.index('asteroid_survey')).to be < phases.index('capture_operation')
      expect(phases.index('capture_operation')).to be < phases.index('hollowing')
      expect(phases.index('hollowing')).to be < phases.index('depot_conversion')
    end

    it 'scores orbital_depot low when there are no moons to leverage' do
      orbital = options.find { |o| o.pattern == :orbital_depot }
      captured = options.find { |o| o.pattern == :captured_asteroid }

      expect(orbital.score).to be < captured.score
    end
  end

  describe 'contrast: the same body WITH moons (luna-first path becomes viable)' do
    let(:moon) { create(:celestial_body, name: 'TestMoon') }
    let(:with_moon_context) do
      no_moon_context.merge(moons: [moon])
    end
    let(:moon_planner) { described_class.new(super_mars, system_context: with_moon_context) }

    it 'raises orbital_depot above the no-moon case (moons add transfer-point value)' do
      no_moon_orbital  = options.find { |o| o.pattern == :orbital_depot }.score
      with_moon_orbital = moon_planner.plan.find { |o| o.pattern == :orbital_depot }.score

      expect(with_moon_orbital).to be > no_moon_orbital
    end
  end

  describe 'scenario invariants (the defining absences)' do
    it 'has no moons in the system context' do
      expect(no_moon_context[:moons]).to be_empty
    end

    it 'has no nearby import nodes (no Earth/Venus analogs)' do
      expect(no_moon_context[:nearby_nodes]).to be_empty
    end

    it 'has a solid surface (so surface_feature is a fair competitor, not the only option)' do
      expect(super_mars.has_solid_surface?).to be true
    end
  end
end
