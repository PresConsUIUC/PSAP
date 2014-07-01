class AddFormatTypeColumnToFormats < ActiveRecord::Migration
  def change
    add_column :formats, :format_type, :integer, null: false,
               default: FormatType::AV
  end
end
