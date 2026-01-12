FactoryBot.define do
  factory :migration_log do
    unit { nil }
    robot { nil }
    source_location_id { 1 }
    source_location_type { "MyString" }
    target_location_id { 1 }
    target_location_type { "MyString" }
    migration_type { "MyString" }
    performed_at { "2025-12-29 18:49:11" }
  end
end
