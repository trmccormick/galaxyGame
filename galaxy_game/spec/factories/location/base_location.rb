# spec/factories/locations/base_location.rb
FactoryBot.define do
  factory :base_location, class: 'Location::BaseLocation' do
    sequence(:name) { |n| "Location #{n}" }
    coordinates { 
      lat = format('%.2f', rand(-90.00..90.00))
      long = format('%.2f', rand(-180.00..180.00))
      ns = lat.to_f >= 0 ? 'N' : 'S'
      ew = long.to_f >= 0 ? 'E' : 'W'
      "#{lat.abs}°#{ns} #{long.abs}°#{ew}"
    }
    location_type { :in_space }

    trait :with_items do
      after(:create) do |location|
        create_list(:item, 3, location: location)
      end
    end
  end
end