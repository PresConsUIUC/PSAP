class RenameRolesPermissionsJoinTable < ActiveRecord::Migration
  def change
    drop_table :roles_permissions
    create_table :permissions_roles do |t|
      t.belongs_to :permission
      t.belongs_to :role
    end
  end
end
