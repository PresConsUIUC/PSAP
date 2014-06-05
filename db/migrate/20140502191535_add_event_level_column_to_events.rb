class AddEventLevelColumnToEvents < ActiveRecord::Migration
  def change
    add_column :events, :event_level, :decimal, precision: 1, scale: 0,
               default: 6 # EventLevel::INFO
    change_column_null :events, :event_level, false
  end
end
