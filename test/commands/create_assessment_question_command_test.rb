require 'test_helper'

class CreateAssessmentQuestionCommandTest < ActiveSupport::TestCase

  def setup
    @valid_params = assessment_questions(:assessment_question_one).attributes
    @valid_params['id'] = nil
    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'
    @command = CreateAssessmentQuestionCommand.new(@valid_params, @user,
                                                   @remote_ip)
  end

  # updateQuestionIndexes
  test 'updateQuestionIndexes should work when a question is supplied' do
    # with zero index
    AssessmentQuestion.all.each_with_index do |question, i|
      question.index = i
    end
    new_question = AssessmentQuestion.create!(name: 'Bla', index: 0, weight: 0,
                                              question_type: AssessmentQuestionType::RADIO,
                                              assessment_section:
                                                  assessment_sections(:assessment_section_one))
    CreateAssessmentQuestionCommand.updateQuestionIndexes new_question
    AssessmentQuestion.order(:index).each_with_index do |question, i|
      assert_equal i, question.index
    end
    assert_equal 0, new_question.index

    # with nonzero index
    AssessmentQuestion.all.each_with_index do |question, i|
      question.index = i
    end

    new_question = AssessmentQuestion.create!(name: 'Bla', index: 1, weight: 0,
                                              question_type: AssessmentQuestionType::RADIO,
                                              assessment_section:
                                                  assessment_sections(:assessment_section_one))
    CreateAssessmentQuestionCommand.updateQuestionIndexes new_question
    AssessmentQuestion.order(:index).each_with_index do |question, i|
      assert_equal i, question.index
    end
    assert_equal 1, new_question.index

    # with last index
    AssessmentQuestion.all.each_with_index do |question, i|
      question.index = i
    end

    new_question = AssessmentQuestion.create!(name: 'Bla',
                                              index: AssessmentQuestion.count,
                                              weight: 0,
                                              question_type: AssessmentQuestionType::RADIO,
                                              assessment_section:
                                                  assessment_sections(:assessment_section_one))
    CreateAssessmentQuestionCommand.updateQuestionIndexes new_question
    AssessmentQuestion.order(:index).each_with_index do |question, i|
      assert_equal i, question.index
    end
    assert_equal AssessmentQuestion.count - 1, new_question.index
  end

  test 'updateQuestionIndexes should work when no question is supplied' do
    AssessmentQuestion.all.each_with_index do |question, i|
      question.index = i * 3
    end
    CreateAssessmentQuestionCommand.updateQuestionIndexes
    AssessmentQuestion.order(:index).each_with_index do |question, i|
      assert_equal i, question.index
    end
  end

  # execute
  test 'execute method should save assessment question if valid' do
    assert_nothing_raised do
      assert_difference 'Event.count' do
        @command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal 'Created assessment question', event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should fail if validation failed' do
    @invalid_params = @valid_params.dup.except('name')
    @command = CreateAssessmentQuestionCommand.new(@invalid_params, @user,
                                                   @remote_ip)
    assert_raises ValidationError do
      assert_difference 'Event.count' do
        @command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Attempted to create assessment question, but failed: Name "\
    "can't be blank",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the created AssessmentQuestion object' do
    assert_kind_of AssessmentQuestion, @command.object
  end

end
