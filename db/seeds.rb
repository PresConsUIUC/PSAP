# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

institution = Institution.create!(name: 'Sample Institution')

# Admin user
admin_user = User.create!(email: 'admin@example.org', first_name: 'Adam',
                          last_name: 'McAdmin', password: 'admin!',
                          password_confirmation: 'admin!',
                          institution: institution)
# Normal user
normal_user = User.create!(email: 'normal@example.org', first_name: 'Nellie',
                           last_name: 'McNormal', password: 'normal',
                           password_confirmation: 'normal',
                           institution: institution)

# Admin role
admin_role = Role.create(key: 'admin', is_admin: true)
admin_role.users << admin_user

# Normal role
normal_role = Role.create(key: 'normal', is_admin: false)
normal_role.users << normal_user

repository = Repository.create!(institution: institution)

location = Location.create!(repository: repository)
