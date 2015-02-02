class AddDublinCoreFormatToFormats < ActiveRecord::Migration
  def change
    add_column :formats, :dublin_core_format, :string
  end
end
