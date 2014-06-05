class CreateResourceDates < ActiveRecord::Migration
  def change
    create_table :resource_dates do |t|
      t.integer :date_type
      t.decimal :begin_year, precision: 4, scale: 0
      t.decimal :begin_month, precision: 2, scale: 0
      t.decimal :begin_day, precision: 2, scale: 0
      t.decimal :end_year, precision: 4, scale: 0
      t.decimal :end_month, precision: 2, scale: 0
      t.decimal :end_day, precision: 2, scale: 0
      t.decimal :year, precision: 4, scale: 0
      t.decimal :month, precision: 2, scale: 0
      t.decimal :day, precision: 2, scale: 0
    end
    add_reference :resource_dates, :resource, index: true

    remove_column :resources, :begin_year
    remove_column :resources, :end_year
    remove_column :resources, :year
  end
end
