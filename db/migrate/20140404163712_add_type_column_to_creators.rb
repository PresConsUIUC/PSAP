class AddTypeColumnToCreators < ActiveRecord::Migration
  def change
    add_column :creators, :type, :integer, default: Creator::Type::PERSON
  end
end
