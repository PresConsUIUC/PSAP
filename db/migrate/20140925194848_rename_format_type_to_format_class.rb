class RenameFormatTypeToFormatClass < ActiveRecord::Migration
  def change
    rename_column :formats, :format_type, :format_class
  end
end
