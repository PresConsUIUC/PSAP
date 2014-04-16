class AddAddressColumnToEvents < ActiveRecord::Migration
  def change
    add_column :events, :address, :string, limit: 45
  end
end
