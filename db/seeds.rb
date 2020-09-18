Order.destroy_all
Account.destroy_all

a = Account.create!(sms: '3606709312', email: 'jesse@anysoft.us', name: 'Test Account')
u = User.create!(email: 'account@test.com', password: ENV.fetch('PASSWORD'), account: a)
c = Credential.create!(user: u, account: a, username: 'jeff')
c.update(token: 'test_token')

3.times do
  m = Menu.create!(account: a, name: Faker::Games::Fallout.location, description: Faker::Lorem.paragraph,
                   sms: '3606709312', email: 'jesse@anysoft.us')

  # Random.rand(0..3).times do
  4.times do
    g = Group.create!(account: a, menu: m, name: Faker::Commerce.department, description: Faker::Lorem.sentence)

    Random.rand(2..7).times do
      p = Product.create!(
        name: Faker::Food.dish,
        account: a,
        menu: m,
        group: g,
        price: Random.rand(0.99..199.9).round(2),
        description: Faker::Lorem.paragraph
      )
    end
  end
end

3.times do
  c = Customer.create!(account: a)
end

# curl -H "Authorization: Token token=QnBWl74yIXRdUcQClUrErAtt" -H "ACCEPT: application/json" http://localhost:3000/menus?deep=true

4.times do
  o = Order.create!(account: a, customer: Customer.all.sample, note: Faker::Lorem.sentence)
  4.times do
    product = Product.all.sample
    OrderItem.create!(
      product: product,
      order: o,
      amount: product.price,
      note: Faker::Lorem.sentence
    )
  end
end

puts "Auth Token: #{Credential.last.token}"
