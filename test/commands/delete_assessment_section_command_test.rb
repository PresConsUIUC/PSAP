require 'test_helper'

class DeleteAssessmentSectionCommandTest < ActiveSupport::TestCase

  def setup
    @section = assessment_sections(:resource_assessment_section_one)

    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'

    @command = DeleteAssessmentSectionCommand.new(@section, @user, @remote_ip)
  end

  # execute
  test 'execute method should delete assessment section' do
    assert_nothing_raised do
      @command.execute
    end
  end

  test 'execute method should write success to event log if successful' do
    assert_difference 'Event.count' do
      assert_difference 'AssessmentSection.count', -1 do
        @command.execute
      end
    end
    assert @section.destroyed?
    event = Event.order(:created_at).last
    assert_equal "Deleted assessment section "\
      "\"#{@section.name}\" in #{@section.assessment.name}", event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should write failure to event log if unsuccessful' do
    skip 'Need to get this to happen'
  end

  # object
  test 'object method should return the deleted AssessmentSection object' do
    assert_kind_of AssessmentSection, @command.object
  end

end
