class RenameLastLoginColumnOnUsers < ActiveRecord::Migration
  def change
    rename_column :users, :last_login, :last_signin
  end
end
