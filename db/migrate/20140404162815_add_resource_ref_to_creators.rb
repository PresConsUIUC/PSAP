class AddResourceRefToCreators < ActiveRecord::Migration
  def change
    add_reference :creators, :resource, index: true
  end
end
