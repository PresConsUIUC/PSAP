class AddAdminToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :is_admin, :boolean, default: false
  end
end
