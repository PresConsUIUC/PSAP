class MakeScoreColumnNullOnFormats < ActiveRecord::Migration
  def change
    change_column :formats, :score, :decimal, precision: 4, scale: 3, null: true
  end
end
