class RenameResourceIdToParentIdInResources < ActiveRecord::Migration
  def change
    rename_column :resources, :resource_id, :parent_id
  end
end
