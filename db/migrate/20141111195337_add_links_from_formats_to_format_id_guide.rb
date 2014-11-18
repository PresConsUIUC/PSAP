class AddLinksFromFormatsToFormatIdGuide < ActiveRecord::Migration
  def change
    add_column :formats, :format_id_guide_page, :string
    add_column :formats, :format_id_guide_anchor, :string
  end
end
