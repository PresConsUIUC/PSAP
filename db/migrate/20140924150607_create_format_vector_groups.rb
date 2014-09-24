class CreateFormatVectorGroups < ActiveRecord::Migration
  def change
    create_table :format_vector_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
