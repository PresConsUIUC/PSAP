# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Seed the database differently depending on the environment.
case Rails.env
  when 'development'
    institution1 = Institution.create!(name: 'University of Illinois at Urbana-Champaign')
    institution2 = Institution.create!(name: 'West Southeast Directional State University')
    institution3 = Institution.create!(name: 'North Northwest Directional State University')
    institution4 = Institution.create!(name: 'East Southwest Directional State University')
    institution5 = Institution.create!(name: 'East Northeast Directional State University')

    # Admin role
    admin_role = Role.create!(name: 'Administrator', is_admin: true)

    inst_admin_role = Role.create!(name: 'Institution Administrator', is_admin: false)

    # Normal role
    normal_role = Role.create!(name: 'User', is_admin: false)

    # Admin user
    admin_user = User.create!(username: 'admin', email: 'admin@example.org',
                              first_name: 'System', last_name: 'Administrator',
                              password: 'admin!', password_confirmation: 'admin!',
                              institution: institution1, role: admin_role)

    # Institution admin user
    inst_admin_user = User.create!(username: 'inst', email: 'inst_admin@example.org',
                                   first_name: 'Institution', last_name: 'Administrator',
                                   password: 'inst_admin', password_confirmation: 'inst_admin',
                                   institution: institution1, role: inst_admin_role)

    # Normal user
    normal_user = User.create!(username: 'normal', email: 'normal@example.org',
                               first_name: 'Normal', last_name: 'User',
                               password: 'normal', password_confirmation: 'normal',
                               institution: institution1, role: normal_role)

    repository = Repository.create!(institution: institution1,
                                    name: 'First Repository')

    location = Location.create!(repository: repository)

    permission = Permission.create!(key: 'institutions.edit_own')
    inst_admin_role.permissions << permission

    permission = Permission.create!(key: 'repositories.edit_own')
    inst_admin_role.permissions << permission

    permission = Permission.create!(key: 'repositories.delete_own')
    inst_admin_role.permissions << permission

    permission = Permission.create!(key: 'users.view_all')
    inst_admin_role.permissions << permission

    permission = Permission.create!(key: 'users.view_all_in_own_institution')
    inst_admin_role.permissions << permission

  else # test or production

end
