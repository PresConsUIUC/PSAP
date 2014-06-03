require 'test_helper'

class UpdateAssessmentSectionCommandTest < ActiveSupport::TestCase

  def setup
    @section = assessment_sections(:assessment_section_one)
    @valid_params = assessment_sections(:assessment_section_one).attributes
    @valid_params.delete('id')
    @valid_params['name'] = 'asdfjkjhasfd'
    @user = users(:admin_user)
    @remote_ip = '10.0.0.1'
    @valid_command = UpdateAssessmentSectionCommand.new(@section,
                                                        @valid_params, @user,
                                                        @remote_ip)

    @invalid_params = @valid_params.dup
    @invalid_params['name'] = ''
    @invalid_command = UpdateAssessmentSectionCommand.new(@section,
                                                          @invalid_params,
                                                          @user, @remote_ip)
  end

  # execute
  test 'execute method should save section if valid' do
    assert_nothing_raised do
      assert_difference 'Event.count' do
        @valid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Updated assessment section "\
    "\"#{@valid_command.object.name}\" in "\
    "#{@valid_command.object.assessment.name}",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should fail if validation failed' do
    assert_raises ValidationError do
      assert_difference 'Event.count' do
        @invalid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Attempted to update assessment section "\
    "\"#{@invalid_command.object.name},\" but failed: Name can't be blank",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'question indexes should update if assessment section index changed' do
    flunk
  end

  # object
  test 'object method should return the AssessmentSection object' do
    assert_kind_of AssessmentSection, @valid_command.object
  end

end
