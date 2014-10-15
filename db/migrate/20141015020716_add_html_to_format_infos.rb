class AddHtmlToFormatInfos < ActiveRecord::Migration
  def change
    add_column :format_infos, :html, :text
  end
end
