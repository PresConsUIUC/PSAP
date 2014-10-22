class RenameFormatInfoToStaticPage < ActiveRecord::Migration
  def change
    rename_table :format_infos, :static_pages
  end
end
