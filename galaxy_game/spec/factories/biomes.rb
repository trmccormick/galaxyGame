# spec/factories/biomes.rb
# spec/factories/biomes.rb
FactoryBot.define do
  factory :biome do
    name { "Tropical Rainforest" }
    temperature_range { 25..30 }
    humidity_range { 70..90 }
    description { "A hot and humid biome" }

    # Traits for invalid scenarios
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
