namespace :psap do

  CIDG_SOURCE_PATH = File.join(Rails.root, 'db', 'seed_data', 'CollectionIDGuide')
  CIDG_DEST_PATH = File.join(Rails.root, 'app', 'assets', 'collection_id_guide')
  HELP_SOURCE_PATH = File.join(Rails.root, 'db', 'seed_data', 'AdvHelp')
  HELP_DEST_PATH = File.join(Rails.root, 'app', 'assets', 'advanced_help')
  MANUAL_SOURCE_PATH = File.join(Rails.root, 'db', 'seed_data', 'UserManual')
  MANUAL_DEST_PATH = File.join(Rails.root, 'app', 'assets', 'user_manual')
  QUESTIONS_SOURCE_PATH = File.join(Rails.root, 'db', 'seed_data',
                                    'questionDependencies.xlsx')

  ##
  # Should be run before psap:seed_html_bundles whenever any images or videos
  # change in any of the db/seed_data subfolders. The resulting images should
  # then be committed to version control.
  #
  # Note: this will generate a lot of nearly-identical images that git
  # recognizes as changed, but that haven't, practically speaking. These
  # should be reverted.
  #
  desc 'Generate derivative images for the static content'
  task generate_derivatives: :environment do
    p = StaticPageImporter.new(HELP_SOURCE_PATH, HELP_DEST_PATH)
    p.generate_derivatives
    p = StaticPageImporter.new(CIDG_SOURCE_PATH, CIDG_DEST_PATH)
    p.generate_derivatives
    p = StaticPageImporter.new(MANUAL_SOURCE_PATH, MANUAL_DEST_PATH)
    p.generate_derivatives
  end

  ##
  # Seeds format & assessment question content. Should be run whenever new
  # formats ore questions are added.
  #
  desc 'Seed assessment questions in the database'
  task seed_assessment_questions: :environment do
    puts 'Deleting existing object formats...'
    Format.where('fid > ?', 999).destroy_all
    puts 'Deleting existing object assessment questions...'
    AssessmentQuestion.where('qid > ?', 1999).destroy_all

    p = AssessmentQuestionImporter.new(QUESTIONS_SOURCE_PATH)
    p.import_all
  end

  ##
  # Should be run (after psap:generate_derivatives, if applicable) whenever
  # content in any of the db/seed_data subfolders changes.
  #
  desc 'Reseed HTML bundles in the database'
  task seed_html_bundles: :environment do
    p = StaticPageImporter.new(HELP_SOURCE_PATH, HELP_DEST_PATH)
    p.reseed
    p = StaticPageImporter.new(CIDG_SOURCE_PATH, CIDG_DEST_PATH)
    p.reseed
    p = StaticPageImporter.new(MANUAL_SOURCE_PATH, MANUAL_DEST_PATH)
    p.reseed
  end

end
