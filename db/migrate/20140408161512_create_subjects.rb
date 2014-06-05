class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :name
      t.timestamps
    end
    add_reference :subjects, :resource, index: true
  end
end
