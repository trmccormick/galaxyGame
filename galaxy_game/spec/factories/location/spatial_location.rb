# spec/factories/locations/spatial_location.rb
FactoryBot.define do
  factory :spatial_location, class: 'Location::SpatialLocation' do
    sequence(:name) { |n| "Space Point #{n}" }
    x_coordinate { rand(-1000.0..1000.0) }
    y_coordinate { rand(-1000.0..1000.0) }
    z_coordinate { rand(-1000.0..1000.0) }
  end
end
