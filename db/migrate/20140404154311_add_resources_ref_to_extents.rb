class AddResourcesRefToExtents < ActiveRecord::Migration
  def change
    remove_reference :resources, :extent
    add_reference :extents, :resource, index: true
  end
end
