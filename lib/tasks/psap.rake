namespace :psap do
  desc 'Process Format ID Guide images. Should be run whenever db/seed_data/FormatIDGuide changes, before db:seed.'
  task process_fidg: :environment do
    FormatIdGuide.new.process_images
  end

  desc 'Updates Format ID Guide content in the database.'
  task update_fidg: :environment do
    FormatIdGuide.new.reseed
  end

end
