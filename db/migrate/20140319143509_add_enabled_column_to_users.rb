class AddEnabledColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :enabled, :boolean, default: false
  end
end
