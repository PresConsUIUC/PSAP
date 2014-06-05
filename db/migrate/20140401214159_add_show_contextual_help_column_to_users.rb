class AddShowContextualHelpColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :show_contextual_help, :boolean, default: true
  end
end
