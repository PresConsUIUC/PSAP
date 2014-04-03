class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :native_name
      t.string :english_name
      t.string :iso639_2_code
    end
  end
end
