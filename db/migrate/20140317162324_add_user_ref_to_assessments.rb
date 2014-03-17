class AddUserRefToAssessments < ActiveRecord::Migration
  def change
    add_reference :assessments, :user, index: true
  end
end
