FactoryBot.define do
  factory :base_life_form, class: 'Biology::BaseLifeForm' do
    # Base attributes
    association :biosphere
    name { "Generic Life Form #{Faker::Number.number(digits: 3)}" }
    complexity { :simple }
    domain { :terrestrial }
    population { 1000 }
    
    # More specific factories
    factory :life_form, class: 'Biology::LifeForm'
    factory :hybrid_life_form, class: 'Biology::HybridLifeForm' do
      properties { { engineered_traits: ['growth_limited'] } }
    end
  end
end