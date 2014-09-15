class AlterPrecisionOfEventsEventLevelColumn < ActiveRecord::Migration
  def change
    change_column :events, :event_level, :decimal, precision: 2, scale: 1
  end
end
