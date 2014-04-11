class AddPercentCompleteColumnToResources < ActiveRecord::Migration
  def change
    add_column :resources, :percent_complete, :float, default: 0
  end
end
