Order.destroy_all
Account.destroy_all

a = Account.create!
u = User.create!(email: 'test@test.com', password: ENV.fetch('PASSWORD'), account: a)
c = Credential.create!(user: u, account: a, username: 'jeff')

1.times do
  m = Menu.create!(account: a, name: Faker::Games::Fallout.location)

  # Random.rand(0..3).times do
  4.times do
    g = Group.create!(account: a, menu: m, name: Faker::Commerce.department)

    Random.rand(2..7).times do
      p = Product.create!(
        name: Faker::Food.dish,
        account: a,
        menu: m,
        group: g,
        price: Random.rand(2..109).round(2)
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
