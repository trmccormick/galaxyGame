# spec/factories/locations/celestial_location.rb
FactoryBot.define do
  factory :celestial_location, class: 'Location::CelestialLocation' do
    sequence(:name) { |n| "Location #{n}" }
    coordinates {
      latitude = rand(-90.00..90.00)
      longitude = rand(-180.00..180.00)
      
      ns = latitude >= 0 ? 'N' : 'S'
      ew = longitude >= 0 ? 'E' : 'W'
      
      "#{format('%.2f', latitude.abs)}°#{ns} #{format('%.2f', longitude.abs)}°#{ew}"
    }
    association :celestial_body
  end
end