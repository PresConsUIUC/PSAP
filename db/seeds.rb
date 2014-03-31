# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# formats
Format.create!(name: 'THESE FORMATS HAVE NOT BEEN FINALIZED', score: 1, obsolete: false)
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
    institution4 = Institution.create!(name: 'San Quentin Prison University')
    institution5 = Institution.create!(name: 'Barnum & Bailey Clown College')
    institution6 = Institution.create!(name: 'Hogwart\'s Academy')
    institution7 = Institution.create!(name: 'University of Life')

    # Admin role
    admin_role = Role.create!(name: 'Administrator', is_admin: true)

    # Normal role
    normal_role = Role.create!(name: 'User', is_admin: false)

    # Admin user
    admin_user = User.create!(username: 'admin', email: 'admin@example.org',
                              first_name: 'Adam', last_name: 'McAdmin',
                              password: 'password', password_confirmation: 'password',
                              institution: institution1, role: admin_role,
                              confirmed: true, enabled: true)
    # Normal user
    normal_user = User.create!(username: 'normal', email: 'normal@example.org',
                               first_name: 'Norm', last_name: 'McNormal',
                               password: 'password', password_confirmation: 'password',
                               institution: institution1, role: normal_role,
                               confirmed: true, enabled: true)
    # Unaffiliated user
    unaffiliated_user = User.create!(username: 'unaffiliated', email: 'unaffiliated@example.org',
                                 first_name: 'Clara', last_name: 'NoInstitution',
                                 password: 'password', password_confirmation: 'password',
                                 institution: nil, role: normal_role,
                                 confirmed: true, enabled: true)
    # Unconfirmed user
    unconfirmed_user = User.create!(username: 'unconfirmed', email: 'unconfirmed@example.org',
                                    first_name: 'Sally', last_name: 'NoConfirmy',
                                    password: 'password', password_confirmation: 'password',
                                    institution: institution2, role: normal_role,
                                    confirmed: false, enabled: false)
    # Disabled user
    disabled_user = User.create!(username: 'disabled', email: 'disabled@example.org',
                                 first_name: 'Johnny', last_name: 'CantDoNothin',
                                 password: 'password', password_confirmation: 'password',
                                 institution: institution2, role: normal_role,
                                 confirmed: true, enabled: false)

    repository = Repository.create!(institution: institution1,
                                    name: 'Sample Repository')
    repository2 = Repository.create!(institution: institution1,
                                    name: 'Another Sample Repository')

    location = Location.create!(name: 'Secret Location', repository: repository)
    location2 = Location.create!(name: 'Over there by the file cabinet', repository: repository)
    location3 = Location.create!(name: 'Back Room', repository: repository)
    location4 = Location.create!(name: 'Front Room', repository: repository)
    location5 = Location.create!(name: 'Side Room', repository: repository)
    location6 = Location.create!(name: 'Hidden Vault', repository: repository)

    resource = Resource.create(name: 'Magna Carta',
                               resource_type: ResourceType::ITEM,
                               location: location)
    resource2 = Resource.create(name: 'Dead Sea Scrolls',
                                resource_type: ResourceType::ITEM,
                                location: location)
    resource3 = Resource.create(name: 'Sears Catalog Collection',
                                resource_type: ResourceType::COLLECTION,
                                location: location2)
    resource4 = Resource.create(name: 'My Old Baseball Card Collection',
                                resource_type: ResourceType::COLLECTION,
                                location: location2)
    resource5 = Resource.create(name: 'Treaty of Verdun',
                                resource_type: ResourceType::ITEM,
                                location: location3)
    resource6 = Resource.create(name: 'Declaration of Paris',
                                resource_type: ResourceType::ITEM,
                                location: location3)
    resource7 = Resource.create(name: 'Cat Fancy Collection',
                                resource_type: ResourceType::COLLECTION,
                                location: location4)

    permission = Permission.create!(key: 'institutions.edit_own')
    admin_role.permissions << permission

    permission = Permission.create!(key: 'repositories.create_own')
    admin_role.permissions << permission

    permission = Permission.create!(key: 'repositories.edit_own')
    admin_role.permissions << permission

    permission = Permission.create!(key: 'repositories.delete_own')
    admin_role.permissions << permission

    permission = Permission.create!(key: 'resources.create_own')
    admin_role.permissions << permission

    permission = Permission.create!(key: 'resources.edit_own')
    admin_role.permissions << permission

    permission = Permission.create!(key: 'resources.delete_own')
    admin_role.permissions << permission

    permission = Permission.create!(key: 'users.view_all')
    admin_role.permissions << permission

    permission = Permission.create!(key: 'users.view_all_in_own_institution')
    admin_role.permissions << permission

end

# Most of the above commands generated events, which we don't want.
Event.destroy_all
