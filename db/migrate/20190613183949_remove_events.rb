class RemoveEvents < ActiveRecord::Migration[5.2]
  def down

  end

  def up
    drop_table :events_assessment_questions, if_exists: true
    drop_table :events_assessment_sections, if_exists: true
    drop_table :events_assessments, if_exists: true
    drop_table :events_formats, if_exists: true
    drop_table :events_institutions, if_exists: true
    drop_table :events_locations, if_exists: true
    drop_table :events_resources, if_exists: true
    drop_table :events_repositories, if_exists: true
    drop_table :events_users, if_exists: true
    drop_table :events, if_exists: true
    remove_column :users, :feed_key
  end
end
