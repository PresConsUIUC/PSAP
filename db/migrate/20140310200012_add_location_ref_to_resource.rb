class AddLocationRefToResource < ActiveRecord::Migration
  def change
    add_reference :resources, :location, index: true
  end
end
