class CreateFormats < ActiveRecord::Migration
  def change
    create_table :formats do |t|
      t.string :name
      t.float :score
      t.boolean :obsolete

      t.timestamps
    end
  end
end
