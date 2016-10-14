namespace :psap do

  CIDG_SOURCE_PATH = File.join(Rails.root, 'db', 'seed_data', 'CollectionIDGuide')
  CIDG_DEST_PATH = File.join(Rails.root, 'app', 'assets', 'collection_id_guide')
  HELP_SOURCE_PATH = File.join(Rails.root, 'db', 'seed_data', 'AdvHelp')
  HELP_DEST_PATH = File.join(Rails.root, 'app', 'assets', 'advanced_help')
  MANUAL_SOURCE_PATH = File.join(Rails.root, 'db', 'seed_data', 'UserManual')
  MANUAL_DEST_PATH = File.join(Rails.root, 'app', 'assets', 'user_manual')

  ##
  # Should be run before psap:seed_static_content whenever any images or videos
  # change in any of the db/seed_data subfolders. The resulting images should
  # then be committed to version control.
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
  # Should be run (after psap:generate_derivatives, if applicable) whenever
  # content in any of the db/seed_data subfolders changes. Safe to run in
  # production.
  #
  desc 'Reseed static content in the database'
  task seed_static_content: :environment do
    p = StaticPageImporter.new(HELP_SOURCE_PATH, HELP_DEST_PATH)
    p.reseed
    p = StaticPageImporter.new(CIDG_SOURCE_PATH, CIDG_DEST_PATH)
    p.reseed
    p = StaticPageImporter.new(MANUAL_SOURCE_PATH, MANUAL_DEST_PATH)
    p.reseed
  end

end
