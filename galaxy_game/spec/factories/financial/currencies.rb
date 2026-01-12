# spec/factories/financial/currencies.rb
FactoryBot.define do
  factory :financial_currency, class: 'Financial::Currency' do
    sequence(:name) { |n| "Currency #{n}" }
    sequence(:symbol) { |n| "C#{n.to_s.rjust(3, '0')}" }
    is_system_currency { false }
    precision { 8 }

    # Trait for GCC - the default system currency
    trait :gcc do
      name { "Galactic Crypto Currency" }
      symbol { "GCC" }
      is_system_currency { true }
      precision { 8 }
    end

    trait :usd do
      name { "United States Dollar" }
      symbol { "USD" }
      is_system_currency { true }
      precision { 2 }
    end

    trait :euro do
      name { "Euro" }
      symbol { "EUR" }
      is_system_currency { true }
      precision { 2 }
    end

    trait :colony_currency do
      sequence(:name) { |n| "#{Faker::Space.planet} Coin #{n}" }
      sequence(:symbol) { |n| "#{Faker::Alphanumeric.alpha(number: 2).upcase}#{n}" }
      is_system_currency { false }
      precision { 4 }
    end
  end

  # Legacy alias for backward compatibility
  factory :currency, class: 'Financial::Currency' do
    sequence(:name) { |n| "Currency #{n}" }
    sequence(:symbol) { |n| "C#{n.to_s.rjust(3, '0')}" }
    is_system_currency { false }
    precision { 8 }

    trait :gcc do
      name { "Galactic Crypto Currency" }
      symbol { "GCC" }
      is_system_currency { true }
      precision { 8 }
    end

    trait :usd do
      name { "United States Dollar" }
      symbol { "USD" }
      is_system_currency { true }
      precision { 2 }
    end

    trait :euro do
      name { "Euro" }
      symbol { "EUR" }
      is_system_currency { true }
      precision { 2 }
    end

    trait :colony_currency do
      sequence(:name) { |n| "#{Faker::Space.planet} Coin #{n}" }
      sequence(:symbol) { |n| "#{Faker::Alphanumeric.alpha(number: 2).upcase}#{n}" }
      is_system_currency { false }
      precision { 4 }
    end
  end
end