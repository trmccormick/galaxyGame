# spec/factories/stars.rb
FactoryBot.define do
    factory :star do
      name { 'Sol' }  # Name for the star
      type_of_star { 'sun' }  # Type of the star (e.g., G-type, red dwarf, etc.)
      age { 4.6e9 }  # Age of the star in billions of years
      mass { 1.989e30 }  # Mass of the star in kilograms
      radius { 6.963e8 }  # Radius of the star in meters
      temperature { 5778 }  # Surface temperature in Kelvin
      life { 10.0 }  # Life expectancy in billions of years
      r_ecosphere { 0.8 }  # Radius of the ecosphere in astronomical units
  
      # Add a callback to calculate luminosity based on the type_of_star
      after(:build) do |star|
        star.luminosity = if star.type_of_star == 'red_dwarf'
                            0.01 * 3.828e26  # Example luminosity for a red dwarf
                          else
                            3.828e26  # Luminosity for a sun-like star
                          end
      end
    end
end

# spec/factories/stars.rb
# FactoryBot.define do
#   factory :star do
#     sequence(:name) { |n| "Star #{n}" }  # Generating unique names for multiple instances
#     type_of_star { 'sun' }  # Type of the star (e.g., G-type, red dwarf, etc.)
#     age { 4.6e9 }  # Age of the star in billions of years
#     mass { 1.989e30 }  # Mass of the star in kilograms
#     radius { 6.963e8 }  # Radius of the star in meters
#     temperature { 5778 }  # Surface temperature in Kelvin
#     life { 10.0 }  # Life expectancy in billions of years
#     r_ecosphere { 0.8 }  # Radius of the ecosphere in astronomical units

#     # Add a callback to calculate luminosity based on the type_of_star
#     after(:build) do |star|
#       star.luminosity = case star.type_of_star
#                         when 'red_dwarf'
#                           0.01 * 3.828e26  # Example luminosity for a red dwarf
#                         when 'blue_giant'
#                           1000 * 3.828e26  # Example luminosity for a blue giant
#                         else
#                           3.828e26  # Default luminosity for a sun-like star
#                         end
#     end
#   end
# end


