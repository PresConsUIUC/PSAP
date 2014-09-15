class ChangeEventsDescriptionToText < ActiveRecord::Migration
  def change
    change_column :events, :description, :text, limit: nil
  end
end
