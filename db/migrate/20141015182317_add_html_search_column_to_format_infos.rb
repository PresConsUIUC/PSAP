class AddHtmlSearchColumnToFormatInfos < ActiveRecord::Migration
  def change
    add_column :format_infos, :searchable_html, :text
  end
end
