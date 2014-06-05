class AddFormatRefToResources < ActiveRecord::Migration
  def change
    add_reference :resources, :format, index: true
  end
end
