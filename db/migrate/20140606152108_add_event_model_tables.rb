class AddEventModelTables < ActiveRecord::Migration
  def change
    create_table :events_assessments, id: false do |t|
      t.belongs_to :assessment
      t.belongs_to :event
    end
    create_table :events_assessment_questions, id: false do |t|
      t.belongs_to :assessment_question
      t.belongs_to :event
    end
    create_table :events_formats, id: false do |t|
      t.belongs_to :format
      t.belongs_to :event
    end
    create_table :events_institutions, id: false do |t|
      t.belongs_to :institution
      t.belongs_to :event
    end
    create_table :events_locations, id: false do |t|
      t.belongs_to :location
      t.belongs_to :event
    end
    create_table :events_repositories, id: false do |t|
      t.belongs_to :repository
      t.belongs_to :event
    end
    create_table :events_resources, id: false do |t|
      t.belongs_to :resource
      t.belongs_to :event
    end
    create_table :events_users, id: false do |t|
      t.belongs_to :user
      t.belongs_to :event
    end
  end
end
