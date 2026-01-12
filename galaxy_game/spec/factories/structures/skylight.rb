# spec/factories/structures/skylight.rb
FactoryBot.define do
  factory :skylight, class: 'Structures::Skylight' do
    diameter { 10 }
    position { 500 }
    association :lava_tube, factory: :lava_tube
    status { "uncovered" }
    
    # Skylight with cover
    trait :covered do
      status { "covered" }
    end
  end
end