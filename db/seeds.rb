# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# formats
format1 = Format.create!(name: '! THESE FORMATS HAVE NOT BEEN FINALIZED !', score: 1, obsolete: false)
format2 = Format.create!(name: '35mm nitrate', score: 0, obsolete: true)
format3 = Format.create!(name: '35mm acetate', score: 0.375, obsolete: true)
format4 = Format.create!(name: '35mm polyester', score: 0.875, obsolete: true)
format5 = Format.create!(name: '16mm acetate', score: 0.375, obsolete: true)
format6 = Format.create!(name: '16mm polyester', score: 0.875, obsolete: true)
format7 = Format.create!(name: '8mm', score: 0.375, obsolete: true)
format8 = Format.create!(name: 'Super 8mm', score: 0.5, obsolete: true)
format9 = Format.create!(name: '9.5mm', score: 0.25, obsolete: true)
format10 = Format.create!(name: 'Other film gauges', score: 0, obsolete: true)

# Admin role
admin_role = Role.create!(name: 'Administrator', is_admin: true)

# Normal role
normal_role = Role.create!(name: 'User', is_admin: false)

# From here, we seed the database differently depending on the environment.
case Rails.env

  when 'development'
    institution1 = Institution.create!(name: 'University of Illinois at Urbana-Champaign',
                                       address1: '1408 W. Gregory Dr.',
                                       address2: nil, city: 'Urbana',
                                       state: 'IL',
                                       postal_code: 61801,
                                       country: 'United States of America',
                                       url: 'http://www.library.illinois.edu/')
    institution2 = Institution.create!(name: 'West Southeast Directional State University',
                                       address1: '1 Directional Drive',
                                       address2: nil, city: 'Podunk',
                                       state: 'IL', postal_code: 12345,
                                       country: 'United States of America',
                                       url: 'http://example.org/')
    institution3 = Institution.create!(name: 'Hamburger University',
                                       address1: '21 Hamburger Place',
                                       address2: nil, city: 'Des Moines',
                                       state: 'IA', postal_code: 12345,
                                       country: 'United States of America',
                                       url: 'http://example.org/')
    institution4 = Institution.create!(name: 'San Quentin Prison University',
                                       address1: '5435 Prison Ct.',
                                       address2: nil, city: 'San Quentin',
                                       state: 'CA', postal_code: 90210,
                                       country: 'United States of America',
                                       url: 'http://example.org/')
    institution5 = Institution.create!(name: 'Barnum & Bailey Clown College',
                                       address1: 'Circus Tent C',
                                       address2: '53 Trapeze Road',
                                       city: 'Los Angeles',
                                       state: 'CA', postal_code: 99999,
                                       country: 'United States of America',
                                       url: 'http://example.org/')
    institution6 = Institution.create!(name: 'Hogwarts School of Witchcraft & Wizardry',
                                       address1: '123 Magical St.',
                                       address2: nil, city: 'Hogsmeade',
                                       state: 'N/A', postal_code: 99999,
                                       country: 'Hogsmeade',
                                       url: 'http://example.org/')

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
                               format: format1, location: location,
                               user: normal_user)
    resource2 = Resource.create(name: 'Dead Sea Scrolls',
                                resource_type: ResourceType::ITEM,
                                format: format2, location: location,
                                user: normal_user)
    resource3 = Resource.create(name: 'Sears Catalog Collection',
                                resource_type: ResourceType::COLLECTION,
                                location: location2, user: admin_user)
    resource4 = Resource.create(name: 'My Old Baseball Card Collection',
                                resource_type: ResourceType::COLLECTION,
                                location: location2, user: admin_user)
    resource5 = Resource.create(name: 'Treaty of Verdun',
                                resource_type: ResourceType::ITEM,
                                format: format5, location: location3,
                                user: normal_user)
    resource6 = Resource.create(name: 'Declaration of Paris',
                                resource_type: ResourceType::ITEM,
                                format: format6, location: location3,
                                user: disabled_user)
    resource7 = Resource.create(name: 'Cat Fancy Collection',
                                resource_type: ResourceType::COLLECTION,
                                location: location4, user: normal_user)
    resource8 = Resource.create(name: 'Issue 1',
                                resource_type: ResourceType::ITEM,
                                location: location4, parent: resource7,
                                user: admin_user)
    resource9 = Resource.create(name: 'Issue 2',
                                resource_type: ResourceType::ITEM,
                                location: location4, parent: resource7,
                                user: disabled_user)
    resource10 = Resource.create(name: 'Special Editions',
                                 resource_type: ResourceType::COLLECTION,
                                 location: location4, parent: resource7,
                                 user: admin_user)
    resource11 = Resource.create(name: '1972 Presidential Election Special Issue',
                                 resource_type: ResourceType::ITEM,
                                 location: location4, parent: resource10,
                                 user: normal_user)
    resource12 = Resource.create(name: 'Issue 3',
                                 resource_type: ResourceType::ITEM,
                                 location: location4, parent: resource7,
                                 user: normal_user)
    resource13 = Resource.create(name: 'Reader\'s Digest Collection',
                                resource_type: ResourceType::COLLECTION,
                                location: location4, user: normal_user)
end

# Most of the above commands generated events, which we don't want.
Event.destroy_all
