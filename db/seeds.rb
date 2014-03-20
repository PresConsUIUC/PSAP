# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# formats
Format.create!(name: '35mm nitrate', score: 0, obsolete: true)
Format.create!(name: '35mm acetate', score: 0.375, obsolete: true)
Format.create!(name: '35mm polyester', score: 0.875, obsolete: true)
Format.create!(name: '16mm acetate', score: 0.375, obsolete: true)
Format.create!(name: '16mm polyester', score: 0.875, obsolete: true)
Format.create!(name: '8mm', score: 0.375, obsolete: true)
Format.create!(name: 'Super 8mm', score: 0.5, obsolete: true)
Format.create!(name: '9.5mm', score: 0.25, obsolete: true)
Format.create!(name: 'Other film gauges', score: 0, obsolete: true)

# From here, we seed the database differently depending on the environment.
case Rails.env

  when 'development'
    institution1 = Institution.create!(name: 'University of Illinois at Urbana-Champaign')
    institution2 = Institution.create!(name: 'West Southeast Directional State University')
    institution3 = Institution.create!(name: 'Hamburger University')
    institution4 = Institution.create!(name: 'Barnum & Bailey Circus Academy')
    institution5 = Institution.create!(name: 'Hogwart\'s Academy')

    # Admin role
    admin_role = Role.create!(name: 'Administrator', is_admin: true)

    inst_admin_role = Role.create!(name: 'Institution Administrator', is_admin: false)

    # Normal role
    normal_role = Role.create!(name: 'User', is_admin: false)

    # Admin user
    admin_user = User.create!(username: 'admin', email: 'admin@example.org',
                              first_name: 'System', last_name: 'Administrator',
                              password: 'admin!', password_confirmation: 'admin!',
                              institution: institution1, role: admin_role,
                              confirmed: true, enabled: true)

    # Institution admin user
    inst_admin_user = User.create!(username: 'inst', email: 'inst_admin@example.org',
                                   first_name: 'Institution', last_name: 'Administrator',
                                   password: 'inst_admin', password_confirmation: 'inst_admin',
                                   institution: institution1, role: inst_admin_role,
                                   confirmed: true, enabled: true)

    # Normal user
    normal_user = User.create!(username: 'normal', email: 'normal@example.org',
                               first_name: 'Normal', last_name: 'User',
                               password: 'normal', password_confirmation: 'normal',
                               institution: institution1, role: normal_role,
                               confirmed: true, enabled: true)

    # Alex
    alex_user = User.create!(username: 'alexd', email: 'alexd@illinois.edu',
                             first_name: 'Alex', last_name: 'Dolski',
                             password: 'password', password_confirmation: 'password',
                             institution: institution1, role: admin_role,
                             confirmed: true, enabled: true)

    # Ryan
    ryan_user = User.create!(username: 'edge2', email: 'edge2@illinois.edu',
                             first_name: 'Ryan', last_name: 'Edge',
                             password: 'password', password_confirmation: 'password',
                             institution: institution1, role: admin_role,
                             confirmed: true, enabled: true)

    repository = Repository.create!(institution: institution1,
                                    name: 'First Repository')

    location = Location.create!(name: 'Secret Location', repository: repository)
    location2 = Location.create!(name: 'Super-Secret Location', repository: repository)
    location3 = Location.create!(name: 'Super-Duper-Secret Location', repository: repository)
    location4 = Location.create!(name: 'Public Location', repository: repository)

    resource = Resource.create(name: 'Magna Carta',
                               resource_type: ResourceType::ITEM,
                               location: location)
    resource2 = Resource.create(name: 'Dead Sea Scrolls',
                                resource_type: ResourceType::ITEM,
                                location: location)
    resource3 = Resource.create(name: 'Sears Catalog Collection',
                                resource_type: ResourceType::COLLECTION,
                                location: location2)
    resource4 = Resource.create(name: 'JC Penney Catalog Collection',
                                resource_type: ResourceType::COLLECTION,
                                location: location2)
    resource5 = Resource.create(name: 'U.S. Constitution',
                                resource_type: ResourceType::ITEM,
                                location: location3)
    resource6 = Resource.create(name: 'Declaration of Independence',
                                resource_type: ResourceType::ITEM,
                                location: location3)
    resource7 = Resource.create(name: 'Cat Fancy Collection',
                                resource_type: ResourceType::COLLECTION,
                                location: location4)
    resource8 = Resource.create(name: 'Tiger Beat Collection',
                                resource_type: ResourceType::COLLECTION,
                                location: location4)

    permission = Permission.create!(key: 'institutions.edit_own')
    inst_admin_role.permissions << permission

    permission = Permission.create!(key: 'repositories.create_own')
    inst_admin_role.permissions << permission

    permission = Permission.create!(key: 'repositories.edit_own')
    inst_admin_role.permissions << permission

    permission = Permission.create!(key: 'repositories.delete_own')
    inst_admin_role.permissions << permission

    permission = Permission.create!(key: 'resources.create_own')
    inst_admin_role.permissions << permission

    permission = Permission.create!(key: 'resources.edit_own')
    inst_admin_role.permissions << permission

    permission = Permission.create!(key: 'resources.delete_own')
    inst_admin_role.permissions << permission

    permission = Permission.create!(key: 'users.view_all')
    inst_admin_role.permissions << permission

    permission = Permission.create!(key: 'users.view_all_in_own_institution')
    inst_admin_role.permissions << permission

  else # test or production

end
