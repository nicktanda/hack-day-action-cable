# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
user = User.create!(name: "Nick", email: "nick.havilah@tanda.co", password: "password")
user_2 = User.create!(name: "Josh", email: "josh@tanda.co", password: "password")
conversation = Conversation.create!
conversation.users << user
conversation.users << user_2
conversation.save!