class AddParentRefToResource < ActiveRecord::Migration
  def change
    add_reference :resources, :resource, index: true
  end
end
