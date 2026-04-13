# frozen_string_literal: true

FactoryBot.define do
  factory :orbital_settlement, class: 'Settlement::OrbitalSettlement' do
    sequence(:name) { |n| "OrbitalSettlement#{n}" }
    # settlement_type deliberately omitted — OrbitalSettlement is a stub pending the
    # architectural refactor in 2026-03-31-HIGH-REFACTOR-ORBITAL-SETTLEMENT-ARCHITECTURE.md
    # New enum values (orbital_station, orbital_depot, etc.) require a migration.
    # DB default (base: 0) satisfies presence validation for now.
    current_population { 0 }
    operational_data { {} }

    association :owner, factory: :development_corporation

    # No direct location association; OrbitalSettlement location is structure-based.


    # Earth/Luna L1 Gateway (launch-heavy)
    trait :earth_luna_l1 do
      operational_data do
        {
          'trait' => 'earth_luna_l1',
          'planned_structures' => [
            {'type' => 'orbital_depot', 'blueprint' => 'orbital_depot_mk1'},
            {'type' => 'space_station', 'blueprint' => 'l1_shipyard_bp'}
          ]
        }
      end
    end

    # Mars Phobos/Deimos (tug Rule B conversion)
    trait :mars_phobos_demios do
      operational_data do
        {
          'trait' => 'mars_phobos_demios',
          'conversion' => {'method' => 'tug_rule_b', 'source' => 'phobos_demios'},
          'planned_structures' => [
            {'type' => 'worldhouse_depot', 'geological_feature' => 'phobos'},
            {'type' => 'worldhouse_shipyard', 'geological_feature' => 'deimos'}
          ]
        }
      end
    end

    # Venus Artificial Moons (asteroid relocation)
    trait :venus_artificial_moons do
      operational_data do
        {
          'trait' => 'venus_artificial_moons',
          'conversion' => {
            'method' => 'tug_asteroid_relocation',
            'source' => 'asteroid_capture',
            'destination' => 'venus_l1',
            'efficiency' => 0.30  # Rule B
          },
          'planned_structures' => [
            {'type' => 'worldhouse_depot', 'source' => 'relocated_asteroid'},
            {'type' => 'worldhouse_shipyard', 'source' => 'relocated_asteroid'}
          ]
        }
      end
    end
  end
end
