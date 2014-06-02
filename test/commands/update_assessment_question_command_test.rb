require 'test_helper'

class UpdateAssessmentQuestionCommandTest < ActiveSupport::TestCase

  def setup
    @question = assessment_questions(:assessment_question_one)
    @valid_params = assessment_questions(:assessment_question_one).attributes
    @valid_params.delete('id')
    @valid_params['name'] = 'asdfjkjhasfd'
    @user = users(:admin_user)
    @remote_ip = '10.0.0.1'
    @valid_command = UpdateAssessmentQuestionCommand.new(@question,
                                                         @valid_params, @user,
                                                         @remote_ip)

    @invalid_params = @valid_params.dup
    @invalid_params['name'] = ''
    @invalid_command = UpdateAssessmentQuestionCommand.new(@question,
                                                           @invalid_params,
                                                           @user, @remote_ip)
  end

  # execute
  test 'execute method should save question if valid' do
    assert_nothing_raised do
      assert_difference 'Event.count' do
        @valid_command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal 'Updated assessment question', event.description
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
    assert_equal "Attempted to update assessment question, but failed: Name "\
    "can't be blank",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'question indexes should update if assessment question index changed' do
    flunk
  end

  # object
  test 'object method should return the AssessmentQuestion object' do
    assert_kind_of AssessmentQuestion, @valid_command.object
  end

end
