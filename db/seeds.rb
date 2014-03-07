# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Admin user
User.create!(email: 'admin@example.org', first_name: 'Adam',
             last_name: 'McAdmin', password: 'admin!',
             password_confirmation: 'admin!')
# Normal user
User.create!(email: 'normal@example.org', first_name: 'Nellie',
             last_name: 'McNormal', password: 'normal',
             password_confirmation: 'normal')
