class AddRepositoryRefToLocations < ActiveRecord::Migration
  def change
    add_reference :locations, :repository, index: true
  end
end
