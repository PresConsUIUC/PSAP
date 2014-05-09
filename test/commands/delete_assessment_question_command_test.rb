require 'test_helper'

class DeleteAssessmentQuestionCommandTest < ActiveSupport::TestCase

  def setup
    @question = assessment_questions(:assessment_question_one)

    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'

    @command = DeleteAssessmentQuestionCommand.new(@question, @user, @remote_ip)
  end

  # execute
  test 'execute method should delete assessment question' do
    assert_nothing_raised do
      @command.execute
    end
  end

  test 'execute method should write success to event log if successful' do
    assert_difference 'Event.count' do
      assert_difference 'AssessmentQuestion.count', -1 do
        @command.execute
      end
    end
    assert @question.destroyed?
    event = Event.order(:created_at).last
    assert_equal 'Assessment question deleted.', event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should write failure to event log if unsuccessful' do
    skip 'Need to get this to happen'
  end

  # object
  test 'object method should return the deleted AssessmentQuestion object' do
    assert_kind_of AssessmentQuestion, @command.object
  end

end
