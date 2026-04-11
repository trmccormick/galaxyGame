# frozen_string_literal: true

FactoryBot.define do
  factory :converted_base, class: 'Structures::ConvertedBase' do
    sequence(:name) { |n| "ConvertedBase#{n}" }
    # host_body is always stubbed in the spec, not set here
  end
end
