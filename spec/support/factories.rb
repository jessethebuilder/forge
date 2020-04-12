FactoryBot.define do
  factory :account do
  end

  factory :credential do
    account
    sequence(:username){ |n| "user#{n}" }
    token { 'a_token' }
  end

  factory :customer do
    account
  end

  factory :menu do
    account
  end

  factory :group do
    account
  end

  factory :product do
    account
    price { Random.rand(0.01..100000.0).round(2) }
  end

  factory :order do
    account
  end

  factory :order_item do
    order
    product
    amount { Random.rand(0.01..100000.0).round(2) }
  end
end
