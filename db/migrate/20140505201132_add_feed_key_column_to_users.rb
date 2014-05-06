class AddFeedKeyColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :feed_key, :string
    change_column_null :users, :feed_key, false
  end
end
