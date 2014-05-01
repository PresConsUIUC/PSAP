class AddEventStatusToEvent < ActiveRecord::Migration
  def change
    add_column :events, :event_status, :decimal, scale: 1, precision: 1
  end
end
