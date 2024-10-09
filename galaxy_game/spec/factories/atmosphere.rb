FactoryBot.define do
    # factory :atmosphere do
    #   celestial_body { association(:celestial_body) }
    #   temperature { 300 }
    #   pressure { 101.3 }
    #   atmosphere_composition { { "O2" => 21, "N2" => 79 } }
    #   total_atmospheric_mass { 1000 }
    # end

    factory :atmosphere do
      temperature { 20 }
      pressure { 1013 }
      association :celestial_body
    end    
end