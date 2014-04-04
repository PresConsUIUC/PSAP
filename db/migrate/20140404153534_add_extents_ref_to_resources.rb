class AddExtentsRefToResources < ActiveRecord::Migration
  def change
    add_reference :resources, :extent, index: true
  end
end
