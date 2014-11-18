namespace :psap do
  desc 'Generate derivative images for the Format ID Guide. Should be run '\
  'whenever the content in db/seed_data/FormatIDGuide changes, before psap:seed_fidg_content.'
  task generate_fidg_derivatives: :environment do
    p = StaticPageImporter.new(
        File.join(Rails.root, 'db', 'seed_data', 'FormatIDGuide-HTML'),
        File.join(Rails.root, 'app', 'assets', 'format_id_guide'))
    p.generate_derivatives
  end

  desc 'Updates Format ID Guide content in the database.'
  task seed_fidg_content: :environment do
    p = StaticPageImporter.new(
        File.join(Rails.root, 'db', 'seed_data', 'FormatIDGuide-HTML'),
        File.join(Rails.root, 'app', 'assets', 'format_id_guide'))
    p.reseed
  end

  desc 'Generate derivative images for the advanced help. Should be run '\
  'whenever the content in db/seed_data/AdvHelp changes, before psap:seed_help_content.'
  task generate_help_derivatives: :environment do
    p = StaticPageImporter.new(
        File.join(Rails.root, 'db', 'seed_data', 'AdvHelp'),
        File.join(Rails.root, 'app', 'assets', 'advanced_help'))
    p.generate_derivatives
  end

  desc 'Updates advanced help content in the database.'
  task seed_help_content: :environment do
    p = StaticPageImporter.new(
        File.join(Rails.root, 'db', 'seed_data', 'AdvHelp'),
        File.join(Rails.root, 'app', 'assets', 'advanced_help'))
    p.reseed
  end
end
