# ------------------------------------------------------------------------------
# 5. USAGE EXAMPLES
# ------------------------------------------------------------------------------

# Example 1: Deploy standard terraforming bacteria
# biosphere = planet.biosphere
# cyano = Biology::LifeFormLibrary.cyanobacteria
# deployment = biosphere.deploy_life_form(cyano, initial_coverage: 5.0)

# Example 2: Check if a life form can survive
# habitability = biosphere.habitability_for(cyano)
# if habitability[:viable]
#   puts "Ready to deploy!"
# else
#   puts "Limiting factors: #{habitability[:limiting_factors].join(', ')}"
# end

# Example 3: Create a hybrid for specific conditions
# hardy_lichen = Biology::LifeFormLibrary.hardy_lichen
# cyano = Biology::LifeFormLibrary.cyanobacteria
# mars_hybrid = Biology::LifeForm.create_hybrid(
#   hardy_lichen, 
#   cyano,
#   name: "Mars-Optimized Photosynthesizer",
#   designer: "Human Terraforming Corps"
# )

# Example 4: Engineer a custom organism
# template = Biology::LifeFormLibrary.nitrogen_fixers
# super_fixer = Biology::LifeForm.engineer_from_template(
#   template,
#   modifications: {
#     name: "Titan Nitrogen Fixer",
#     designer: "Europa Institute",
#     n_multiplier: 3.0,          # 3x nitrogen fixation
#     min_temp: 90.0,             # Can survive Titan temperatures
#     max_temp: 200.0,
#     required_gases: ['N2', 'CH4']  # Adapted for Titan atmosphere
#   }
# )

# Example 5: Run terraforming simulation
# # Each game "year" that passes:
# biosphere.apply_terraforming_effects(time_delta_years: 10)
# 
# # Check deployment status and update
# biosphere.life_form_deployments.active.each do |deployment|
#   habitability = biosphere.habitability_for(deployment.life_form)
#   deployment.update_status_and_coverage(habitability)
# end
#
# # Check results
# puts "O2 production rate: #{biosphere.oxygen_production_rate} kg/year"
# puts "Soil quality: #{biosphere.soil_quality}/100"
# puts "Biodiversity score: #{biosphere.biodiversity_score}"