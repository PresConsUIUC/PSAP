class AddTypeColumnToCreators < ActiveRecord::Migration
  def change
    add_column :creators, :type, :integer, default: CreatorType::PERSON
  end
end
