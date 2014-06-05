class RemoveKeyFromRole < ActiveRecord::Migration
  def change
    remove_column :roles, :key
  end
end
