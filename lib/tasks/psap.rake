namespace :psap do
  desc 'Process Format ID Guide images. Should be run whenever db/seed_data/FormatIDGuide changes, before db:seed.'
  task process_fidg: :environment do
    FormatIdGuide.new.process_images
  end

end
