class CreateFormatInkMediaTypes < ActiveRecord::Migration
  def change
    create_table :format_ink_media_types do |t|
      t.string :name
      t.decimal :score, precision: 4, scale: 3, null: false
      t.integer :group
      t.integer :format_id
      t.integer :format_vector_group_id

      t.timestamps
    end
  end
end
