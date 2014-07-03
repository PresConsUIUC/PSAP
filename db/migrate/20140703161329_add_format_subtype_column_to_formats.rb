class AddFormatSubtypeColumnToFormats < ActiveRecord::Migration
  def change
    add_column :formats, :format_subtype, :integer
  end
end
