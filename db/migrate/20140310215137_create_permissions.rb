class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.string :key

      t.timestamps
    end
  end
end
