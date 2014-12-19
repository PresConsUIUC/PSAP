# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Languages

puts 'Seeding languages...'

languages = []
# This file is from http://www.loc.gov/standards/iso639-2/ISO-639-2_utf-8.txt
File.open('db/seed_data/ISO-639-2_utf-8.txt', 'r') do |file|
  while line = file.gets
    parts = line.split('|')
    languages << Language.create(english_name: parts[3], native_name: parts[4],
                                 iso639_2_code: parts[0])
  end
end

puts 'Seeding formats...'

xls = Roo::Spreadsheet.open('db/seed_data/assessment_questions.xlsx')

# Formats
sheet = xls.sheet('Format Scores')
sheet.each_with_index do |row, i|
  if i > 0 # skip header row
    name = parent = nil
    (2..5).reverse_each do |col|
      if name.blank? and !row[col].blank?
        name = row[col]
        if col > 2 # find its parent FID by iterating backwards
          (0..i).reverse_each do |j|
            if sheet.row(j)[col].blank?
              parent = Format.find_by_fid(sheet.row(j)[1])
              break
            end
          end
        else
          parent = nil
        end
      end
    end
    unless name.blank?
      format = Format.new(
          fid: row[1],
          name: name,
          format_class: FormatClass::class_for_name(row[0]),
          parent: parent,
          score: row[6],
          format_id_guide_page: row[7],
          format_id_guide_anchor: row[8])
      unless row[9].blank? # temperature ranges
        min_temps = row[9].split(',')
        max_temps = row[10].split(',')
        temp_scores = row[11].split(',')
        min_temps.each_with_index do |min_temp, i|
          format.temperature_ranges << TemperatureRange.create!(
              min_temp_f: i == 0 ? nil : min_temp.strip.to_i,
              max_temp_f: i == max_temps.length - 1 ? nil : max_temps[i].strip.to_i,
              score: temp_scores[i].strip.to_f)
        end
      end
      unless row[12].blank? # relative humidity ranges
        min_rhs = row[12].split(',')
        max_rhs = row[13].split(',')
        rh_scores = row[14].split(',')
        min_rhs.each_with_index do |min_rh, i|
          format.humidity_ranges << HumidityRange.create!(
              min_rh: min_rh.strip.to_i,
              max_rh: max_rhs[i].strip.to_i,
              score: rh_scores[i].strip.to_f)
        end
      end
      format.save!
    end
  end
end

# Format Vector Groups & Ink/Media Types
xls.sheet('InkMedia Scores').each_with_index do |row, i|
  FormatInkMediaType.create!(name: row[0], score: row[4]) if i > 0 # skip header row
end

# Format Support Types
xls.sheet('Support Scores').each_with_index do |row, i|
  FormatSupportType.create!(name: row[0], score: row[4]) if i > 0 # skip header row
end

# Assessments
assessments = {
    resource: Assessment.create!(name: 'Resource Assessment', key: 'resource'),
    location: Assessment.create!(name: 'Location Assessment', key: 'location'),
    institution: Assessment.create!(name: 'Institution Assessment', key: 'institution')
}

# Resource assessment sections
sections = {}
sections[:use_access] = AssessmentSection.create!(
    name: 'Use | Access', index: 0,
    description: 'The following questions concern the level of use/handling '\
    'of the object(s).',
    assessment: assessments[:resource])
sections[:storage_container] = AssessmentSection.create!(
    name: 'Storage | Container', index: 1,
    description: 'The following questions concern the appropriateness of '\
    'storage, housing, and labeling.',
    assessment: assessments[:resource])
sections[:condition] = AssessmentSection.create!(
    name: 'Condition', index: 2,
    description: 'The following questions concern the physical state of the '\
    'resource, and to what degree this impacts its content.',
    assessment: assessments[:resource])

# Location assessment sections
sections[:location_environment] = AssessmentSection.create!(
    name: 'Environment', index: 0,
    description: 'This section addresses the climate (temperature, humidity) '\
    'of this location, as well as your ability to monitor and respond to it.',
    assessment: assessments[:location])
sections[:location_emergency_preparedness] = AssessmentSection.new(
    name: 'Emergency Preparedness', index: 1,
    description: 'This section concerns the safety mechanisms and disaster '\
    'readiness of this facility in the event of a disaster.',
    assessment: assessments[:location])

# Institution assessment sections
sections[:institution_collection_planning] = AssessmentSection.create!(
    name: 'Collection Planning', index: 0,
    description: 'This section concerns your institution\'s collection '\
    'development policy and level of preservation planning.',
    assessment: assessments[:institution])
sections[:institution_use_access] = AssessmentSection.create!(
    name: 'Use | Access', index: 1,
    description: 'This section concerns your institution\'s practices '\
    'regarding collection description, surrogates/copies, loans, and use '\
    'supervision.',
    assessment: assessments[:institution])
sections[:institution_material_inspection] = AssessmentSection.create!(
    name: 'Material Inspection', index: 2,
    description: 'This section addresses the inspection, cleaning, and repair '\
    'of collection materials at your institution.',
    assessment: assessments[:institution])

sections[:institution_playback_equipment] = AssessmentSection.create!(
    name: 'Playback Equipment', index: 3,
    description: 'This section concerns the equipment used to access certain '\
    'formats (e.g. audiovisual, microfilm) at your institution.',
    assessment: assessments[:institution])

sections[:institution_security] = AssessmentSection.create!(
    name: 'Security', index: 4,
    description: 'This section addresses security of collections at your '\
    'institution.',
    assessment: assessments[:institution])

sections[:institution_disaster_recovery] = AssessmentSection.create!(
    name: 'Disaster Recovery', index: 5,
    description: 'This section concerns the readiness of your institution in '\
    'the event of a disaster.',
    assessment: assessments[:institution])

# Resource assessment questions
puts 'Seeding resource assessment questions...'
aq_sheets = %w(Resource-Paper-Unbound Resource-Photo Resource-AV Resource-Paper-Bound)
aq_sheets.each do |sheet|
  xls.sheet(sheet).each_with_index do |row, index|
    if index > 0 and !row[7].blank? # skip header & trailing rows
      params = {
          qid: row[6].to_i,
          name: row[7].strip,
          question_type: (!row[12].blank? and row[12].downcase == 'checkboxes') ?
              AssessmentQuestionType::CHECKBOX : AssessmentQuestionType::RADIO,
          index: index,
          weight: row[9].to_f,
          help_text: row[8].strip,
          advanced_help_page: nil, # TODO: fix
          advanced_help_anchor: nil # TODO: fix
      }
      case row[5][0..2].strip.downcase
        when 'use'
          params[:assessment_section] = sections[:use_access]
        when 'sto'
          params[:assessment_section] = sections[:storage_container]
        else
          params[:assessment_section] = sections[:condition]
      end

      unless row[10].blank? or row[10].to_s.include?('TBD') or row[11].blank?
        params[:parent] = AssessmentQuestion.find_by_qid(row[10].to_i)
        params[:enabling_assessment_question_options] = []
        row[11].split(';').map{ |x| x.strip }.each do |dep|
          eaqo = params[:parent].assessment_question_options.where(name: dep)[0]
          if eaqo
            params[:enabling_assessment_question_options] << eaqo
          else
            puts 'AQO error: QID ' + row[10].to_s + ': ' + dep
          end
        end
      end

      params[:formats] = Format.where('fid IN (?)',
                                      row[4].to_s.split(';').map{ |f| f.strip.to_i })

      question = AssessmentQuestion.create!(params)

      question.assessment_question_options << AssessmentQuestionOption.new(
          name: row[13], index: 0, value: row[14]) if row[13] and row[14]
      question.assessment_question_options << AssessmentQuestionOption.new(
          name: row[15], index: 1, value: row[16]) if row[15] and row[16]
      question.assessment_question_options << AssessmentQuestionOption.new(
          name: row[17], index: 2, value: row[18]) if row[17] and row[18]
      question.assessment_question_options << AssessmentQuestionOption.new(
          name: row[19], index: 3, value: row[20]) if row[19] and row[20]
      question.assessment_question_options << AssessmentQuestionOption.new(
          name: row[21], index: 4, value: row[22]) if row[21] and row[22]
      question.save!
    end
  end
end

# Location & Institution assessment questions
puts 'Seeding location assessment questions...'
aq_sheets = %w(Location Institution)
aq_sheets.each do |sheet|
  xls.sheet(sheet).each_with_index do |row, index|
    if index > 0 and !row[2].blank? # skip header & trailing rows
      params = {
          qid: row[1].to_i,
          name: row[2].strip,
          question_type: AssessmentQuestionType::RADIO,
          index: index,
          weight: row[6].to_f,
          help_text: row[3].strip,
          advanced_help_page: row[4] ? row[4].strip.gsub('.html', '') : nil,
          advanced_help_anchor: row[5] ? row[5].strip : nil
      }
      case row[0][0..2].strip.downcase
        when 'col'
          params[:assessment_section] = sections[:institution_collection_planning]
        when 'dis'
          params[:assessment_section] = sections[:institution_disaster_recovery]
        when 'env'
          params[:assessment_section] = sections[:location_environment]
        when 'eme'
          params[:assessment_section] = sections[:location_emergency_preparedness]
        when 'mat'
          params[:assessment_section] = sections[:institution_material_inspection]
        when 'pla'
          params[:assessment_section] = sections[:institution_playback_equipment]
        when 'sec'
          params[:assessment_section] = sections[:institution_security]
        when 'use'
          params[:assessment_section] = sections[:institution_use_access]
      end

      unless row[9].blank? or row[8].blank?
        params[:parent] = AssessmentQuestion.find_by_qid(row[7].to_i)
        params[:enabling_assessment_question_options] = []
        row[8].split(';').map{ |x| x.strip }.each do |dep|
          eaqo = params[:parent].assessment_question_options.where(name: dep)[0]
          if eaqo
            params[:enabling_assessment_question_options] << eaqo
          else
            puts 'AQO error: QID ' + row[7].to_s + ': ' + dep
          end
        end
      end

      question = AssessmentQuestion.create!(params)

      question.assessment_question_options << AssessmentQuestionOption.new(
          name: row[9], index: 0, value: row[10]) if row[9] and row[10]
      question.assessment_question_options << AssessmentQuestionOption.new(
          name: row[11], index: 1, value: row[12]) if row[11] and row[12]
      question.assessment_question_options << AssessmentQuestionOption.new(
          name: row[13], index: 2, value: row[14]) if row[13] and row[14]
      question.assessment_question_options << AssessmentQuestionOption.new(
          name: row[15], index: 3, value: row[16]) if row[15] and row[16]
      question.assessment_question_options << AssessmentQuestionOption.new(
          name: row[17], index: 4, value: row[18]) if row[17] and row[18]
      question.save!
    end
  end
end

# Format ID Guide HTML pages
puts 'Ingesting Format ID Guide content...'
p = StaticPageImporter.new(
    File.join(Rails.root, 'db', 'seed_data', 'FormatIDGuide-HTML'),
    File.join(Rails.root, 'app', 'assets', 'format_id_guide'))
p.reseed

# Advanced Help HTML pages
puts 'Ingesting advanced help content...'
p = StaticPageImporter.new(
    File.join(Rails.root, 'db', 'seed_data', 'AdvHelp'),
    File.join(Rails.root, 'app', 'assets', 'advanced_help'))
p.reseed

puts 'Creating the admin user...'

# Admin role
admin_role = Role.create!(name: 'Administrator', is_admin: true)

# Normal role
normal_role = Role.create!(name: 'User', is_admin: false)

# Admin user
command = CreateUserCommand.new(
    { username: 'admin', email: 'admin@example.org',
      first_name: 'Admin', last_name: 'Admin',
      password: 'password', password_confirmation: 'password',
      confirmed: true, enabled: true }, '127.0.0.1', false)
command.execute
admin_user = command.object
admin_user.role = admin_role
admin_user.save!

# UIUC institution
command = CreateAndJoinInstitutionCommand.new(
    { name: 'University of Illinois at Urbana-Champaign',
      address1: '1408 W. Gregory Dr.',
      address2: nil,
      city: 'Urbana',
      state: 'IL',
      postal_code: 61801,
      country: 'United States of America',
      url: 'http://www.library.illinois.edu/',
      email: 'test@example.org',
      language: languages[122],
      description: 'Lorem ipsum dolor sit amet' }, admin_user, '127.0.0.1')
command.execute
uiuc_institution = command.object
admin_user.institution = uiuc_institution
admin_user.save!

# From here, we seed the database differently depending on the environment.
case Rails.env

  when 'development'
    puts 'Seeding DEVELOPMENT data...'

    # Institution assessment question responses
    Assessment.find_by_key('institution').assessment_questions.each do |question|
        uiuc_institution.assessment_question_responses <<
            AssessmentQuestionResponse.create!(
                institution: uiuc_institution,
                assessment_question: question,
                assessment_question_option: question.assessment_question_options.first)
    end
    uiuc_institution.save!

    # Institutions
    CreateAndJoinInstitutionCommand.new(
        { name: 'Hogwarts School of Witchcraft & Wizardry',
          address1: '123 Magical St.',
          address2: 'Suite 12',
          city: 'Hogsmeade',
          state: 'N/A',
          postal_code: 99999,
          country: 'Hogsmeade',
          url: 'http://example.org/',
          email: 'test@example.org',
          description: 'Lorem ipsum dolor sit amet' }, nil, '127.0.0.1').execute
    hogwarts_institution = command.object

    # Normal user
    command = CreateUserCommand.new(
        { username: 'normal', email: 'normal@example.org',
          first_name: 'Norm', last_name: 'McNormal',
          password: 'password', password_confirmation: 'password',
          institution: uiuc_institution, role: normal_role,
          confirmed: true, enabled: true }, '127.0.0.1', false)
    command.execute
    normal_user = command.object

    # Unaffiliated user
    command = CreateUserCommand.new(
        { username: 'unaffiliated', email: 'unaffiliated@example.org',
          first_name: 'Clara', last_name: 'NoInstitution',
          password: 'password', password_confirmation: 'password',
          institution: nil, role: normal_role,
          confirmed: true, enabled: true }, '127.0.0.1', false)
    command.execute
    unaffiliated_user = command.object

    # Unconfirmed user
    command = CreateUserCommand.new(
        { username: 'unconfirmed', email: 'unconfirmed@example.org',
          first_name: 'Sally', last_name: 'NoConfirmy',
          password: 'password', password_confirmation: 'password',
          institution: uiuc_institution, role: normal_role,
          confirmed: false, enabled: false }, '127.0.0.1', false)
    command.execute
    unconfirmed_user = command.object

    # Disabled user
    command = CreateUserCommand.new(
        { username: 'disabled', email: 'disabled@example.org',
          first_name: 'Johnny', last_name: 'CantDoNothin',
          password: 'password', password_confirmation: 'password',
          institution: uiuc_institution, role: normal_role,
          confirmed: true, enabled: false }, '127.0.0.1', false)
    command.execute
    disabled_user = command.object

    # User who desires to change institutions
    command = CreateUserCommand.new(
        { username: 'hpotter', email: 'harry@example.org',
          first_name: 'Harry', last_name: 'Potter',
          password: 'password', password_confirmation: 'password',
          institution: hogwarts_institution,
          desired_institution: Institution.find_by_city('Hogsmeade'),
          role: normal_role,
          confirmed: true, enabled: true }, '127.0.0.1', false)
    command.execute

    # Repositories
    repository_commands = [
        CreateRepositoryCommand.new(uiuc_institution,
            { name: 'Sample Repository' }, nil, '127.0.0.1'),
        CreateRepositoryCommand.new(uiuc_institution,
            { name: 'Another Sample Repository' }, nil, '127.0.0.1')
    ]

    repositories = repository_commands.map{ |command| command.execute; command.object }

    # Locations
    location_commands = [
        CreateLocationCommand.new(repositories[0],
            { name: 'Secret Location',
              description: 'Sample description' }, nil, '127.0.0.1'),
        CreateLocationCommand.new(repositories[0],
            { name: 'Even More Secret Location',
              description: 'Sample description' }, nil, '127.0.0.1'),
        CreateLocationCommand.new(repositories[0],
            { name: 'Attic',
              description: 'Sample description' }, nil, '127.0.0.1'),
    ]

    locations = location_commands.map{ |command| command.execute; command.object }

    locations.each do |location|
      location.temperature_range = TemperatureRange.create!(
          min_temp_f: 60, max_temp_f: 70, score: 1)
      location.save!
    end

    # Location assessment question responses
    Assessment.find_by_key('location').assessment_questions.each do |question|
        locations[0].assessment_question_responses <<
            AssessmentQuestionResponse.create!(
                location: locations[0],
                assessment_question: question,
                assessment_question_option: question.assessment_question_options.first)
    end
    locations[0].save!

    # Resources
    resource_commands = []
    resource_commands << CreateResourceCommand.new(
        locations[0],
        { name: 'Sample Collection',
          resource_type: ResourceType::COLLECTION,
          assessment_type: AssessmentType::ITEM_LEVEL,
          user: normal_user,
          description: 'Sample description',
          local_identifier: 'sample_local_id',
          significance: 0,
          rights: 'Sample rights' }, nil, '127.0.0.1')
    resource_commands << CreateResourceCommand.new(
        locations[0],
        { name: 'Sample Assessed Albumen Print Resource',
          resource_type: ResourceType::ITEM,
          format: Format.find_by_fid(7),
          user: normal_user,
          description: 'Sample description',
          local_identifier: 'sample_local_id',
          significance: 1,
          rights: 'Sample rights' }, nil, '127.0.0.1')
    resource_commands << CreateResourceCommand.new(
        locations[0],
        { name: 'Sample Assessed Bound Paper Resource',
          resource_type: ResourceType::ITEM,
          format: Format.find_by_fid(160),
          format_ink_media_type: FormatInkMediaType.find(2),
          format_support_type: FormatSupportType.find(2),
          user: normal_user,
          description: 'Sample description',
          local_identifier: 'sample_local_id',
          significance: 1,
          rights: 'Sample rights' }, nil, '127.0.0.1')
    resource_commands << CreateResourceCommand.new(
        locations[0],
        { name: 'Sample Assessed Original Document Resource',
          resource_type: ResourceType::ITEM,
          format: Format.find_by_fid(159),
          format_ink_media_type: FormatInkMediaType.find(3),
          format_support_type: FormatSupportType.find(3),
          user: normal_user,
          description: 'Sample description',
          local_identifier: 'sample_local_id',
          significance: 1,
          rights: 'Sample rights' }, nil, '127.0.0.1')
    resource_commands << CreateResourceCommand.new(
        locations[1],
        { name: 'Collection Containing Lots of Items',
          resource_type: ResourceType::COLLECTION,
          assessment_type: AssessmentType::SAMPLE,
          user: admin_user,
          description: 'Sample description',
          local_identifier: 'sample_local_id',
          significance: 0,
          rights: 'Sample rights' }, nil, '127.0.0.1')
    resource_commands << CreateResourceCommand.new(
        locations[2],
        { name: 'Sample collection with a really long name. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ut lorem leo. Phasellus varius vitae lorem eget facilisis. Suspendisse nulla massa, pretium nec lorem eget, sodales bibendum magna. Interdum et mal',
          resource_type: ResourceType::COLLECTION,
          assessment_type: AssessmentType::ITEM_LEVEL,
          user: normal_user,
          description: 'Sample description',
          local_identifier: 'sample_local_id',
          rights: 'Sample rights' }, nil, '127.0.0.1')
    resource_commands << CreateResourceCommand.new(
        locations[2],
        { name: 'Issue 1',
          resource_type: ResourceType::ITEM,
          user: admin_user,
          description: 'Sample description',
          local_identifier: 'sample_local_id',
          rights: 'Sample rights' }, nil, '127.0.0.1')
    resource_commands << CreateResourceCommand.new(
        locations[2],
        { name: 'Issue 2',
          resource_type: ResourceType::ITEM,
          user: disabled_user,
          description: 'Sample description',
          local_identifier: 'sample_local_id',
          rights: 'Sample rights' }, nil, '127.0.0.1')
    (0..100).each do
      resource_commands << CreateResourceCommand.new(
          locations[1],
          { name: 'Sample Multitudinous Top-Level Item',
            resource_type: ResourceType::ITEM,
            user: normal_user,
            description: 'Sample description',
            local_identifier: 'sample_local_id',
            rights: 'Sample rights' }, nil, '127.0.0.1')
    end

    resources = resource_commands.map{ |command| command.execute; command.object }
    resource_commands = []

    (0..100).each do
      resource_commands << CreateResourceCommand.new(
          locations[1],
          { name: 'Sample Multitudinous Child Item',
            resource_type: ResourceType::ITEM,
            user: normal_user,
            parent: resources[4],
            description: 'Sample description',
            local_identifier: 'sample_local_id',
            rights: 'Sample rights' }, nil, '127.0.0.1')
    end

    resources += resource_commands.map{ |command| command.execute; command.object }

    # Resource assessment question responses
    [1, 2, 3].each do |i|
      resources[i].format.assessment_questions.each do |question|
        resources[i].assessment_question_responses <<
            AssessmentQuestionResponse.create!(
                resource: resources[i],
                assessment_question: question,
                assessment_question_option: question.assessment_question_options.first)
      end
    end

    resources[1].parent = resources[0]
    resources[2].parent = resources[0]
    resources[3].parent = resources[0]
    resources[6].parent = resources[5]
    resources[7].parent = resources[5]
    resources.each{ |r| r.save! }

    # Dates
    ResourceDate.create!(resource: resources[0],
                         date_type: DateType::SINGLE,
                         year: 1995)
    ResourceDate.create!(resource: resources[1],
                         date_type: DateType::SINGLE,
                         year: 1986)
    ResourceDate.create!(resource: resources[2],
                         date_type: DateType::BULK,
                         begin_year: 30,
                         end_year: 50)
    ResourceDate.create!(resource: resources[3],
                         date_type: DateType::SPAN,
                         begin_year: 1920,
                         end_year: 1990)
    ResourceDate.create!(resource: resources[4],
                         date_type: DateType::BULK,
                         begin_year: 1980,
                         end_year: 1992)
    ResourceDate.create!(resource: resources[5],
                         date_type: DateType::SINGLE,
                         year: 843)
    ResourceDate.create!(resource: resources[6],
                         date_type: DateType::SINGLE,
                         year: 1856)
    ResourceDate.create!(resource: resources[7],
                         date_type: DateType::SINGLE,
                         year: 1856)

    # Extents
    extents = []
    for i in 0..resources.length / 2
      extents << Extent.create!(name: 'Sample extent',
                                resource: resources[i])
    end
    for i in 0..resources.length / 3
      extents << Extent.create!(name: 'Another sample extent',
                                resource: resources[i])
    end

    # Creators
    creators = []
    for i in 0..resources.length - 1
      creators << Creator.create!(name: 'Sample creator',
                                  creator_type: i.odd? ? CreatorType::PERSON : CreatorType::COMPANY,
                                  resource: resources[i])
    end

    # Notes
    notes = []
    for i in 0..resources.length - 1
      notes << ResourceNote.create!(value: 'Sample note 1',
                                    resource: resources[i])
      notes << ResourceNote.create!(value: 'Sample note 2',
                                    resource: resources[i])
    end

    # Subjects
    subjects = []
    for i in 0..resources.length - 1
      subjects << Subject.create!(name: 'Sample subject',
                                  resource: resources[i])
    end

    # Events
    Event.create!(description: 'This event was just created',
                  event_level: EventLevel::DEBUG,
                  user: normal_user,
                  address: '127.0.0.1',
                  created_at: Time.mktime(2014, 4, 12))
    Event.create!(description: 'Made queso dip, but ran out of chips before '\
    'the queso was consumed, so had to buy more chips, but then didn\'t have '\
    'enough queso',
                  event_level: EventLevel::INFO,
                  user: admin_user,
                  address: '10.252.52.5',
                  created_at: Time.mktime(2014, 2, 6))
    Event.create!(description: 'Gazed into the abyss',
                  event_level: EventLevel::NOTICE,
                  user: disabled_user,
                  address: '10.252.52.5',
                  created_at: Time.mktime(2013, 11, 10, 2, 5, 10))
    Event.create!(description: 'Abyss gazed back',
                  event_level: EventLevel::NOTICE,
                  user: disabled_user,
                  address: '10.252.52.5',
                  created_at: Time.mktime(2013, 11, 10, 2, 5, 11))
    Event.create!(description: 'Meta-Ambulation has pulled ahead in Pedometer Challenge',
                  event_level: EventLevel::WARNING,
                  address: '127.0.0.1',
                  created_at: Time.mktime(2014, 3, 26))
    Event.create!(description: 'Godzilla has appeared in Tokyo Harbor',
                  event_level: EventLevel::ERROR,
                  user: admin_user,
                  address: '10.5.2.6',
                  created_at: Time.mktime(2014, 5, 8))
    Event.create!(description: 'Skynet has become self-aware',
                  event_level: EventLevel::CRITICAL,
                  address: '127.0.0.1',
                  created_at: Time.mktime(1997, 8, 12))
    Event.create!(description: 'Ran out of toilet paper',
                  event_level: EventLevel::ALERT,
                  address: '127.0.0.1',
                  created_at: Time.mktime(2013, 6, 19))
    (0..250).each do
      Event.create!(description: 'Sample event',
                    event_level: EventLevel::DEBUG,
                    address: '127.0.0.1',
                    created_at: Time.mktime(2012, 12, 12))
    end

end

puts 'Done'
