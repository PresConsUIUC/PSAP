##
# Used by several "psap:" rake tasks to process and ingest help
# content from the HTML files in db/seed_data/Help-HTML. # TODO
#
class Help

  SOURCE_PATH = File.join(Rails.root, 'db', 'seed_data', 'Help-HTML') # TODO
  ASSET_PATH = File.join(Rails.root, 'app', 'assets', 'help') # TODO
  DEST_PATH = ASSET_PATH

  include ContentProcessing

end
