class RemoveObsoleteColumnFromFormats < ActiveRecord::Migration
  def change
    remove_column :formats, :obsolete
  end
end
