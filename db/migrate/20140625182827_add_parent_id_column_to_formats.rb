class AddParentIdColumnToFormats < ActiveRecord::Migration
  def change
    add_column :formats, :parent_id, :integer
    add_index :formats, :parent_id
  end
end
