# Create a main sample user.
User.create!(name: "Example User",
              email: "example@railstutorial.org",
              password: "foobar",
              password_confirmation: "foobar",
              admin:     true,
              activated: true,
              activated_at: Time.zone.now)
# Generate a bunch of additional users.
99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name: name,
              email: email,
              password: password,
              password_confirmation: password,
              activated: true,
              activated_at: Time.zone.now)
end

users = User.order(:created_at).take(6)
50.times do |n|
  users.each do |user|
    content = Faker::Lorem.sentence
    user.microposts.create!(content: content)
  end
end

users = User.all
user = User.first
following = users[2..50]
followers = users[3..40]
following.each{|followed| user.follow(followed)}
followers.each{|follower| follower.follow(user)}
