class RenameResetPasswordKeyColumnOnUsers < ActiveRecord::Migration
  def change
    rename_column :users, :reset_password_key, :password_reset_key
  end
end
