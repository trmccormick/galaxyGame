# spec/factories/biomes.rb
FactoryBot.define do
  factory :biome do
    # Use SecureRandom.uuid for guaranteed uniqueness
    name { "Biome-#{SecureRandom.uuid}" } # Or just SecureRandom.uuid if you don't need a prefix
    
    # Use Kelvin ranges that match your test cases
    temperature_range { 298..303 }  # ~25-30°C in Kelvin, includes both 28°C (301K) and 301K
    humidity_range { 70..90 }       # Includes the test value of 80%
    description { "A standard biome for testing" }

    trait :tropical_rainforest do
      # If you use this trait, you'll need to ensure its name is unique too
      # or only use it in contexts where uniqueness isn't an issue.
      # For example:
      name { "Tropical Rainforest-#{SecureRandom.uuid}" }
      temperature_range { 295..310 } # 22-37°C
      humidity_range { 75..100 }     # 75-100% humidity
      description { "Hot, humid, and dense with vegetation" }
    end

    trait :temperate_forest do
      name { "Temperate Forest-#{SecureRandom.uuid}" }
      temperature_range { 275..295 } # 2-22°C
      humidity_range { 60..80 }      # 60-80% humidity
      description { "Moderate temperature with seasonal changes" }
    end

    trait :desert do
      name { "Desert-#{SecureRandom.uuid}" }
      temperature_range { 290..320 } # 17-47°C
      humidity_range { 10..30 }      # 10-30% humidity
      description { "Hot and dry with sparse vegetation" }
    end

    trait :tundra do
      name { "Tundra-#{SecureRandom.uuid}" }
      temperature_range { 240..265 } # -33 to -8°C
      humidity_range { 40..60 }      # 40-60% humidity
      description { "Cold with low-growing vegetation and permafrost" }
    end

    # Traits for invalid scenarios (keep as is)
    trait :without_name do
      name { nil }
    end

    trait :without_temperature_range do
      temperature_range { nil }
    end

    trait :without_humidity_range do
      humidity_range { nil }
    end
  end
end