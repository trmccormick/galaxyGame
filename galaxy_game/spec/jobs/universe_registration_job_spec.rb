# spec/jobs/universe_registration_job_spec.rb
require 'rails_helper'

RSpec.describe UniverseRegistrationJob, type: :job do
  describe '#validate_system_envelope!' do
    let(:valid_planet) do
      { "name" => "Test Planet", "orbits" => [{ "semi_major_axis_au" => 1.5 }] }
    end

    let(:subject_job) { described_class.new }

    describe 'wormhole count validation' do
      it 'raises when wormhole count exceeds MAX_WORMHOLES_PER_SYSTEM (full seed format)' do
        seed = { "celestial_bodies" => { "terrestrial_planets" => [valid_planet] }, "wormholes" => [{}, {}, {}, {}] }
        expect { subject_job.validate_system_envelope!(seed) }
          .to raise_error(described_class::InvalidSystemBoundariesError, /Wormhole count/)
      end

      it 'raises when wormhole count exceeds MAX_WORMHOLES_PER_SYSTEM (simplified format)' do
        seed = { planets: [valid_planet], wormholes: [{}, {}, {}, {}] }
        expect { subject_job.validate_system_envelope!(seed) }
          .to raise_error(described_class::InvalidSystemBoundariesError, /Wormhole count/)
      end

      it 'does not raise when wormhole count equals MAX_WORMHOLES_PER_SYSTEM' do
        seed = { "celestial_bodies" => { "terrestrial_planets" => [valid_planet] }, "wormholes" => [{}, {}, {}] }
        expect { subject_job.validate_system_envelope!(seed) }.not_to raise_error
      end

      it 'does not raise when wormhole count is below MAX_WORMHOLES_PER_SYSTEM' do
        seed = { "celestial_bodies" => { "terrestrial_planets" => [valid_planet] }, "wormholes" => [{}] }
        expect { subject_job.validate_system_envelope!(seed) }.not_to raise_error
      end

      it 'does not raise when wormholes key is missing (full seed format)' do
        seed = { "celestial_bodies" => { "terrestrial_planets" => [valid_planet] } }
        expect { subject_job.validate_system_envelope!(seed) }.not_to raise_error
      end

      it 'does not raise when wormholes is nil (full seed format)' do
        seed = { "celestial_bodies" => { "terrestrial_planets" => [valid_planet] }, "wormholes" => nil }
        expect { subject_job.validate_system_envelope!(seed) }.not_to raise_error
      end

      it 'does not raise when wormholes is empty array (full seed format)' do
        seed = { "celestial_bodies" => { "terrestrial_planets" => [valid_planet] }, "wormholes" => [] }
        expect { subject_job.validate_system_envelope!(seed) }.not_to raise_error
      end
    end

    describe 'inner boundary validation' do
      it 'raises when planet is inside inner boundary (< 1 AU) — full seed format' do
        seed = { "celestial_bodies" => { "terrestrial_planets" => [{ "name" => "Too Close", "orbits" => [{ "semi_major_axis_au" => 0.5 }] }] }, "wormholes" => [] }
        expect { subject_job.validate_system_envelope!(seed) }
          .to raise_error(described_class::InvalidSystemBoundariesError, /inside inner boundary/)
      end

      it 'raises when planet is inside inner boundary (< 1 AU) — simplified format' do
        seed = { planets: [{ name: "Too Close", orbits: [{ semi_major_axis_au: 0.5 }] }], wormholes: [] }
        expect { subject_job.validate_system_envelope!(seed) }
          .to raise_error(described_class::InvalidSystemBoundariesError, /inside inner boundary/)
      end

      it 'does not raise when planet is exactly at inner boundary (1 AU)' do
        seed = { "celestial_bodies" => { "terrestrial_planets" => [{ "name" => "At Boundary", "orbits" => [{ "semi_major_axis_au" => 1.0 }] }] }, "wormholes" => [] }
        expect { subject_job.validate_system_envelope!(seed) }.not_to raise_error
      end
    end

    describe 'outer boundary validation' do
      it 'raises when planet exceeds outer boundary (> 100 AU) — full seed format' do
        seed = { "celestial_bodies" => { "terrestrial_planets" => [{ "name" => "Too Far", "orbits" => [{ "semi_major_axis_au" => 150.0 }] }] }, "wormholes" => [] }
        expect { subject_job.validate_system_envelope!(seed) }
          .to raise_error(described_class::InvalidSystemBoundariesError, /exceeds outer boundary/)
      end

      it 'raises when planet exceeds outer boundary (> 100 AU) — simplified format' do
        seed = { planets: [{ name: "Too Far", orbits: [{ semi_major_axis_au: 150.0 }] }], wormholes: [] }
        expect { subject_job.validate_system_envelope!(seed) }
          .to raise_error(described_class::InvalidSystemBoundariesError, /exceeds outer boundary/)
      end

      it 'does not raise when planet is exactly at outer boundary (100 AU)' do
        seed = { "celestial_bodies" => { "terrestrial_planets" => [{ "name" => "At Boundary", "orbits" => [{ "semi_major_axis_au" => 100.0 }] }] }, "wormholes" => [] }
        expect { subject_job.validate_system_envelope!(seed) }.not_to raise_error
      end
    end

    describe 'valid seeds' do
      it 'does not raise for a valid seed within all bounds (full seed format)' do
        seed = { "celestial_bodies" => { "terrestrial_planets" => [valid_planet] }, "wormholes" => [{}] }
        expect { subject_job.validate_system_envelope!(seed) }.not_to raise_error
      end

      it 'does not raise for a valid seed within all bounds (simplified format)' do
        seed = { planets: [valid_planet], wormholes: [{}] }
        expect { subject_job.validate_system_envelope!(seed) }.not_to raise_error
      end

      it 'does not raise for a seed with no wormholes' do
        seed = { "celestial_bodies" => { "terrestrial_planets" => [valid_planet] }, "wormholes" => [] }
        expect { subject_job.validate_system_envelope!(seed) }.not_to raise_error
      end

      it 'does not raise for a seed with no planets' do
        seed = { "celestial_bodies" => { "terrestrial_planets" => nil }, "wormholes" => [] }
        expect { subject_job.validate_system_envelope!(seed) }.not_to raise_error
      end

      it 'does not raise for a seed with no celestial_bodies key' do
        seed = { "wormholes" => [] }
        expect { subject_job.validate_system_envelope!(seed) }.not_to raise_error
      end

      it 'handles planets with missing orbits gracefully' do
        seed = { "celestial_bodies" => { "terrestrial_planets" => [{ "name" => "No Orbit" }] }, "wormholes" => [] }
        expect { subject_job.validate_system_envelope!(seed) }.not_to raise_error
      end

      it 'handles planets with zero semi_major_axis_au gracefully' do
        seed = { "celestial_bodies" => { "terrestrial_planets" => [{ "name" => "Zero Orbit", "orbits" => [{ "semi_major_axis_au" => 0 }] }] }, "wormholes" => [] }
        expect { subject_job.validate_system_envelope!(seed) }.not_to raise_error
      end

      it 'handles multiple planets — raises on first invalid' do
        seed = {
          "celestial_bodies" => {
            "terrestrial_planets" => [
              { "name" => "Valid Planet", "orbits" => [{ "semi_major_axis_au" => 1.5 }] },
              { "name" => "Too Close", "orbits" => [{ "semi_major_axis_au" => 0.5 }] }
            ]
          },
          "wormholes" => []
        }
        expect { subject_job.validate_system_envelope!(seed) }
          .to raise_error(described_class::InvalidSystemBoundariesError, /Too Close/)
      end

      it 'handles multiple planets — passes when all valid' do
        seed = {
          "celestial_bodies" => {
            "terrestrial_planets" => [
              { "name" => "Inner Planet", "orbits" => [{ "semi_major_axis_au" => 1.5 }] },
              { "name" => "Outer Planet", "orbits" => [{ "semi_major_axis_au" => 50.0 }] }
            ]
          },
          "wormholes" => [{}]
        }
        expect { subject_job.validate_system_envelope!(seed) }.not_to raise_error
      end
    end

    describe 'AU to meters conversion' do
      it 'correctly converts 1 AU to meters' do
        # 1 AU = 1.496e11 m, SAFE_DISTANCE = 1.496e11 (1 AU)
        au = 1.0
        distance_m = au * 1.496e11
        expect(distance_m).to eq(GameConstants::SAFE_DISTANCE_FROM_STAR)
      end

      it 'correctly converts 100 AU to meters' do
        au = 100.0
        distance_m = au * 1.496e11
        expect(distance_m).to eq(GameConstants::MAX_DISTANCE_FROM_STAR)
      end
    end
  end
end
