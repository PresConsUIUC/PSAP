class RenameFormatIdGuideColumnsToCollectionIdColumns < ActiveRecord::Migration
  def change
    rename_column :formats, :format_id_guide_anchor, :collection_id_guide_anchor
    rename_column :formats, :format_id_guide_page, :collection_id_guide_page
  end
end
