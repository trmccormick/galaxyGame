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
    association :location, factory: :celestial_location

    after(:build) do |settlement|
      if settlement.respond_to?(:create_account_and_inventory)
        settlement.define_singleton_method(:create_account_and_inventory) { nil }
      end
      settlement.build_inventory if settlement.inventory.nil?
      if settlement.respond_to?(:build_units_and_modules)
        settlement.define_singleton_method(:build_units_and_modules) { true }
      end
    end
  end
end
