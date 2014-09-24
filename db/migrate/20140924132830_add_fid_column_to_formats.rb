class AddFidColumnToFormats < ActiveRecord::Migration
  def change
    add_column :formats, :fid, :integer
  end
end
