# spec/factories/solar_systems.rb
FactoryBot.define do
    factory :solar_system do
      name { "Alpha123" }
  
      factory :solar_system_with_star do
        after(:create) do |solar_system|
          create(:star, solar_system: solar_system)
        end
      end
    end
end