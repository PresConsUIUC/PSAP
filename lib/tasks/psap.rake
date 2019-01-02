namespace :psap do

  CIDG_SOURCE_PATH      = File.join(Rails.root, 'db', 'seed_data', 'CollectionIDGuide')
  CIDG_DEST_PATH        = File.join(Rails.root, 'app', 'assets', 'collection_id_guide')
  HELP_SOURCE_PATH      = File.join(Rails.root, 'db', 'seed_data', 'AdvHelp')
  HELP_DEST_PATH        = File.join(Rails.root, 'app', 'assets', 'advanced_help')
  MANUAL_SOURCE_PATH    = File.join(Rails.root, 'db', 'seed_data', 'UserManual')
  MANUAL_DEST_PATH      = File.join(Rails.root, 'app', 'assets', 'user_manual')
  QUESTIONS_SOURCE_PATH = File.join(Rails.root, 'db', 'seed_data', 'questionDependencies.xlsx')

  desc 'Export all of an institution\'s data (except users) to JSON'
  task :export_institution, [:id] => [:environment] do |task, args|
    inst = Institution.find(args[:id])
    puts JSON.pretty_generate(inst.full_export_as_json)
  end

  ##
  # Should be run before psap:seed_html_bundles whenever any images or videos
  # change in any of the db/seed_data subfolders. The resulting images should
  # then be committed to version control.
  #
  # Note: this will generate a lot of nearly-identical images that git
  # recognizes as changed, but haven't, practically. These should be reverted.
  #
  desc 'Generate derivative images for the static content'
  task generate_derivatives: :environment do
    StaticPageImporter.new(HELP_SOURCE_PATH, HELP_DEST_PATH).generate_derivatives
    StaticPageImporter.new(CIDG_SOURCE_PATH, CIDG_DEST_PATH).generate_derivatives
    StaticPageImporter.new(MANUAL_SOURCE_PATH, MANUAL_DEST_PATH).generate_derivatives
  end

  ##
  # Seeds format & assessment question content. Should be run whenever new
  # formats or questions are added.
  #
  desc 'Seed assessment questions in the database'
  task seed_assessment_questions: :environment do
    AssessmentQuestionImporter.new(QUESTIONS_SOURCE_PATH).import_all
  end

  ##
  # Should be run (after psap:generate_derivatives, if applicable) whenever
  # content in any of the db/seed_data subfolders changes.
  #
  desc 'Reseed HTML bundles in the database'
  task seed_html_bundles: :environment do
    StaticPageImporter.new(HELP_SOURCE_PATH, HELP_DEST_PATH).reseed
    StaticPageImporter.new(CIDG_SOURCE_PATH, CIDG_DEST_PATH).reseed
    StaticPageImporter.new(MANUAL_SOURCE_PATH, MANUAL_DEST_PATH).reseed
  end

end
