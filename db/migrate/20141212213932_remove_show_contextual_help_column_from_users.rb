class RemoveShowContextualHelpColumnFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :show_contextual_help
  end
end
