# spec/factories/structures/access_point.rb
FactoryBot.define do
  factory :access_point, class: 'Structures::AccessPoint' do
    sequence(:name) { |n| "Access Point #{n}" }
    access_type { 'large' }
    conversion_status { 'uncovered' }
    association :lava_tube, factory: :lava_tube_feature
    # Only valid attributes; 'status' removed
  end
end
