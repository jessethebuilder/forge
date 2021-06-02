FactoryBot.define do
  factory :account do
    sequence(:email){ |n| "test_#{n}@test.com" }
  end

  factory :credential do
    account
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
    price { Random.rand(0.01..1000.0).round(2) }
    account
  end

  factory :order do
    account

    trait :with_items do
      transient do
        count { 1 }
      end

      after(:build) do |order, evaluator|
        evaluator.count.times do
          order.order_items << build(:order_item)
        end
      end
    end
  end

  factory :order_item do
    order
    product
    amount { product.price }
  end

  factory :transaction do
    order
    amount{ Random.rand(1..100000) }

    factory :charge do
      amount { order.total }
    end

    factory :refund do
      amount { (Random.rand(0..order.total) - order.total) }
    end
  end
end
