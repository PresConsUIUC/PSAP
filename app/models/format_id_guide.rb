##
# Used by several "psap:" rake tasks to process and ingest Format ID Guide
# content from the HTML files in db/seed_data/FormatIDGuide-HTML.
#
class FormatIdGuide

  SOURCE_PATH = File.join(Rails.root, 'db', 'seed_data', 'FormatIDGuide-HTML')
  ASSET_PATH = File.join(Rails.root, 'app', 'assets', 'format_id_guide')
  DEST_PATH = ASSET_PATH

  include ContentProcessing

end
