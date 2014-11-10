namespace :psap do
  desc 'Generate derivative images for the Format ID Guide. Should be run '\
  'whenever the content in db/seed_data/FormatIDGuide changes, before psap:update_fidg_content.'
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

end
