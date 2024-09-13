require 'rails_helper'

RSpec.feature "Planets", type: :feature do
  scenario "User views a planet detail" do
    # Adding required attributes to satisfy the validation
    planet = Planet.create!(
      name: "Earth",
      size: 12742.0, # Example value in kilometers
      gravity: 9.8, # Example value for Earth's gravity in m/s²
      density: 5.51, # Example value for Earth's density in g/cm³
      orbital_period: 365.25, # Example value in days
      total_pressure: 10.0, # Example value for total pressure in atmospheres
      gas_quantities: { "Nitrogen" => 780800.0, "Oxygen" => 209500.0 }
    )

    visit planet_path(planet)

    # Adjusting the expected text to match the format in the view
    expect(page).to have_content("Nitrogen: 780800.0")  # Ensure this matches your view output
    expect(page).to have_content("Oxygen: 209500.0")   # Ensure this matches your view output
  end

  scenario "User updates a planet" do
    planet = Planet.create!(
      name: "Earth", 
      size: 12742.0, 
      gravity: 9.8,
      density: 5.51,
      orbital_period: 365.25,
      total_pressure: 10.0,
      gas_quantities: { "Nitrogen" => 780800.0, "Oxygen" => 209500.0 }
    )
    visit edit_planet_path(planet)
    fill_in "Name", with: "Updated Earth"
    click_button "Update Planet"
    expect(page).to have_content("Updated Earth")
  end

  scenario "User updates a planet" do
    planet = Planet.create!(
      name: "Earth",
      size: 12742.0,
      total_pressure: 10.0, 
      gas_quantities: { "Nitrogen" => 780800.0, "Oxygen" => 209500.0 }
    )

    visit edit_planet_path(planet)
    fill_in "Name", with: "Updated Earth"
    fill_in "Size", with: 13000.0
    fill_in "Total pressure", with: 12.0
    # Ensure the gas quantities are correctly formatted or adjusted if needed
    fill_in "Gas quantities Nitrogen", with: 800000.0
    fill_in "Gas quantities Oxygen", with: 210000.0
    click_button "Update Planet"

    expect(page).to have_content("Updated Earth")
    expect(page).to have_content("Size: 13000.0")
    expect(page).to have_content("Total pressure: 12.0")
    expect(page).to have_content("Gas quantities Nitrogen: 800000.0")
    expect(page).to have_content("Gas quantities Oxygen: 210000.0")
  end
end
