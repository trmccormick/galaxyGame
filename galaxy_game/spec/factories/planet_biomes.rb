FactoryBot.define do
    factory :planet_biome do
      association :biome
      association :celestial_body
    end
end
  