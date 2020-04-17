FactoryBot.define do
  factory :account do
  end

  factory :user do
    account
    sequence(:email){ |n| "test_#{n}@test.com" }
    password { ENV.fetch('PASSWORD') }
  end

  factory :credential do
    account
    sequence(:username){ |n| "user#{n}" }
    sequence(:token){ |n| "user_token_#{n}" }
  end

  factory :customer do
    account
  end

  factory :menu do
    name { Faker::Lorem.word }
    account
  end

  factory :group do
    name { Faker::Lorem.word }
    account
  end

  factory :product do
    name { Faker::Lorem.word }
    price { Random.rand(0.01..100000.0).round(2) }
    account
  end

  factory :order do
    account
  end

  factory :order_item do
    order
    product
    amount { product.price }
  end
end
