DatabaseCleaner.clean

10.times do |n|
  User.create(
    email: "email#{n}@gmail.com",
    password: "111111",
    confirmed_at: DateTime.now
  )
end
