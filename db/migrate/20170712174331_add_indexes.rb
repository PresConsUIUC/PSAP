class AddIndexes < ActiveRecord::Migration
  def change
    add_index :assessment_question_options, :index
    add_index :assessment_questions, :index
    add_index :assessment_sections, :index
    add_index :assessments, :key
    add_index :events, :event_level
    add_index :formats, :format_class
    add_index :resources, :assessment_complete
  end
end
