class RemoveNotesColumnFromResources < ActiveRecord::Migration
  def change
    remove_column :resources, :notes
  end
end
