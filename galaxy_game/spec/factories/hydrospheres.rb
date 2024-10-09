# spec/factories/hydrospheres.rb
FactoryBot.define do
  factory :hydrosphere do
    oceans { 1000 }
    lakes { 500 }
    rivers { 200 }
    ice { 300 }
    celestial_body { association(:celestial_body) }

    trait :earth do
      lakes { 1.25e16 }          # Volume of lakes
      rivers { 2.12e13 }         # Volume of rivers
      oceans { 1.332e21 }        # Volume of oceans
      ice { 2.0e19 }             # Volume of ice
    end

    trait :mars do
      oceans { 0 }
      lakes { 0 }
      rivers { 0 }
      ice { 0 }
    end

    trait :other_planet do
      oceans { 1000 }
      lakes { 500 }
      rivers { 200 }
      ice { 300 }
    end
  end
end
  
  