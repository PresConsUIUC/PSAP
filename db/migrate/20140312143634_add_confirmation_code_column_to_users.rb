class AddConfirmationCodeColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :confirmation_code, :string
  end
end
