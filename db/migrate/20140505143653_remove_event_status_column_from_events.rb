class RemoveEventStatusColumnFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :event_status
  end
end
