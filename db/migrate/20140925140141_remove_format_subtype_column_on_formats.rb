class RemoveFormatSubtypeColumnOnFormats < ActiveRecord::Migration
  def change
    remove_column :formats, :format_subtype
  end
end
