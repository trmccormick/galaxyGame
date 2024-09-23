FactoryBot.define do
  factory :material do
    sequence(:name) { |n| "Sample Material #{n}" }
    amount { 10.0 }
    melting_point { 300 }   # Example default melting point in Kelvin
    boiling_point { 500 }   # Example default boiling point in Kelvin
    vapor_pressure { 0.5 }  # Example vapor pressure in Pascals

    celestial_body { association(:celestial_body) }
  end
end
