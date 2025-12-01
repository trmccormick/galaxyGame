require 'rails_helper'

RSpec.feature "TerrestrialPlanets", type: :feature do
  scenario "User views a planet detail" do
    planet = FactoryBot.create(:terrestrial_planet,
      name: "Earth",
      size: 12742.0,
      gravity: 9.8,
      density: 5.51,
      orbital_period: 365.25,
      known_pressure: 10.0
    )
    planet.reload
    planet.atmosphere.update!(
      pressure: 10.0,
      total_atmospheric_mass: 10000000.0,
      composition: { "Nitrogen" => 78.08, "Oxygen" => 20.95 }
    )

    visit terrestrial_planet_path(planet)

    expect(page).to have_content("Nitrogen: 7808000.0")
    expect(page).to have_content("Oxygen: 2095000.0")
  end

  scenario "User updates a planet's name only" do
    planet = FactoryBot.create(:terrestrial_planet,
      name: "Earth",
      size: 12742.0,
      gravity: 9.8,
      density: 5.51,
      orbital_period: 365.25,
      known_pressure: 10.0
    )
    FactoryBot.create(:atmosphere,
      celestial_body: planet,
      pressure: 10.0,
      composition: { "Nitrogen" => 78.08, "Oxygen" => 20.95 }
    )
    
    visit edit_celestial_body_path(planet)
    
    # Extract the actual error message
    if page.status_code == 500
      error_title = page.find('h1', text: /Error/).text rescue "No h1 found"
      error_detail = page.find('h2').text rescue "No h2 found"
      puts "\n=== ERROR ==="
      puts "Title: #{error_title}"
      puts "Detail: #{error_detail}"
      
      # Try to find the actual error message in pre tags
      page.all('pre').first(3).each_with_index do |pre, i|
        puts "\nPre tag #{i}: #{pre.text[0..200]}"
      end
      puts "=== END ERROR ===\n"
    end
    
    fill_in "Name", with: "Updated Earth"
    click_button "Update"
    
    expect(page).to have_content("Updated Earth")
  end

  scenario "User updates a planet with all attributes" do
    planet = FactoryBot.create(:terrestrial_planet,
      name: "Earth",
      size: 12742.0,
      known_pressure: 10.0
    )
    FactoryBot.create(:atmosphere,
      celestial_body: planet,
      pressure: 10.0,
      composition: { "Nitrogen" => 78.08, "Oxygen" => 20.95 }
    )

    # Use celestial_body route
    visit edit_celestial_body_path(planet)
    
    fill_in "Name", with: "Updated Earth"
    fill_in "Size", with: 13000.0
    
    click_button "Update"

    expect(page).to have_content("Updated Earth")
    expect(page).to have_content("13000.0")
  end
end