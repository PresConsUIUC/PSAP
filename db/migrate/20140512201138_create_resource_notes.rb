class CreateResourceNotes < ActiveRecord::Migration
  def change
    create_table :resource_notes do |t|
      t.text :value
      t.timestamps
    end
    add_reference :resource_notes, :resource, index: true
  end
end
