# spec/factories/locations/base_location.rb
FactoryBot.define do
  factory :base_location, class: 'Location::BaseLocation' do
    sequence(:name) { |n| "Location #{n}" }
    # coordinates removed from base class
    # location_type removed from base class

    trait :with_items do
      after(:create) do |location|
        create_list(:item, 3, location: location)
      end
    end
  end
end