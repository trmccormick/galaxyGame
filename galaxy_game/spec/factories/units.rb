# spec/factories/units.rb
FactoryBot.define do
    factory :base_unit, class: 'Units::BaseUnit' do        
      name { "Test Unit" }
      unit_type { "factory" }
      capacity { 10 }
      energy_cost { 5 }
      production_rate { 2 }
      material_list { { "Power" => 10, "steel" => 10 } }
  
      # Associate with a location if needed
      association :location
    end
end