class RenameTypeColumnOnCreatorsToCreatorType < ActiveRecord::Migration
  def change
    rename_column :creators, :type, :creator_type
  end
end
