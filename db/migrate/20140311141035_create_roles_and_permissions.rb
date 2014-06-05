class CreateRolesAndPermissions < ActiveRecord::Migration
  def change
    create_table :roles_permissions do |t|
      t.belongs_to :role
      t.belongs_to :permission
    end
  end
end
