class RemoveUpdatedColumnFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :updated_at
  end
end
