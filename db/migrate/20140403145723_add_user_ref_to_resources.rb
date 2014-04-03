class AddUserRefToResources < ActiveRecord::Migration
  def change
    add_reference :resources, :user, index: true
  end
end
