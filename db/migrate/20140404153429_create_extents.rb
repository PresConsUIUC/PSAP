class CreateExtents < ActiveRecord::Migration
  def change
    create_table :extents do |t|
      t.string :name
    end
  end
end
