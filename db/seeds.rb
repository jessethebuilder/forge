Account.destroy_all

a = Account.create
u = User.create(email: 'test@test.com', password: ENV.fetch('PASSWORD'), account: a)
c = Credential.create(user: u, account: a, username: 'jeff')

1.times do
  m = Menu.create(account: a, name: Faker::Lorem.word)

  # Random.rand(0..3).times do
  3.times do
    g = Group.create(account: a, menu: m, name: Faker::Lorem.word)
    # g = Group.create(account: a, name: Faker::Lorem.word)

    # Random.rand(0..3).times do
    3.times do
      p = Product.create(account: a, menu: m, group: g)
      # p = Product.create(account: a, menu: m)
      # p = Product.create(account: a)
    end
  end
end
