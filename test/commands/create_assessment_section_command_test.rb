require 'test_helper'

class CreateAssessmentSectionCommandTest < ActiveSupport::TestCase

  def setup
    @valid_params = assessment_sections(:assessment_section_one).attributes
    @valid_params['name'] = 'adfasfd'
    @valid_params['id'] = nil
    @user = users(:normal_user)
    @remote_ip = '10.0.0.1'
    @command = CreateAssessmentSectionCommand.new(@valid_params, @user,
                                                   @remote_ip)
  end

  # updateSectionIndexes
  test 'updateSectionIndexes should work when a section is supplied' do
    # with zero index
    AssessmentSection.all.each_with_index do |section, i|
      section.index = i
    end
    new_section = AssessmentSection.create!(
        name: 'qwerqwererwq', index: 0, weight: 0.5,
        assessment: assessments(:resource_assessment))
    CreateAssessmentSectionCommand.updateSectionIndexes(new_section)
    AssessmentSection.order(:index).each_with_index do |section, i|
      assert_equal i, section.index
    end
    assert_equal 0, new_section.index

    # with nonzero index
    AssessmentSection.all.each_with_index do |section, i|
      section.index = i
    end

    new_section = AssessmentSection.create!(
        name: 'adfasdfsadf', index: 1, weight: 0.5,
        assessment: assessments(:resource_assessment))
    CreateAssessmentSectionCommand.updateSectionIndexes new_section
    AssessmentSection.order(:index).each_with_index do |section, i|
      assert_equal i, section.index
    end
    assert_equal 1, new_section.index

    # with last index
    AssessmentSection.all.each_with_index do |section, i|
      section.index = i
    end

    new_section = AssessmentSection.create!(
        name: 'cxvzxvcxzv', index: AssessmentSection.count, weight: 0.5,
        assessment: assessments(:resource_assessment))
    CreateAssessmentSectionCommand.updateSectionIndexes new_section
    AssessmentSection.order(:index).each_with_index do |section, i|
      assert_equal i, section.index
    end
    assert_equal AssessmentSection.count - 1, new_section.index
  end

  test 'updateSectionIndexes should work when no section is supplied' do
    AssessmentSection.all.each_with_index do |section, i|
      section.index = i * 3
    end
    CreateAssessmentSectionCommand.updateSectionIndexes
    AssessmentSection.order(:index).each_with_index do |section, i|
      assert_equal i, section.index
    end
  end

  # execute
  test 'execute method should save assessment section if valid' do
    assert_nothing_raised do
      assert_difference 'Event.count' do
        @command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Created assessment section \"#{@command.object.name}\" in "\
    "#{@command.object.assessment.name}",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  test 'execute method should fail if validation failed' do
    @invalid_params = @valid_params.dup.except('name')
    @command = CreateAssessmentSectionCommand.new(@invalid_params, @user,
                                                  @remote_ip)
    assert_raises RuntimeError do
      assert_difference 'Event.count' do
        @command.execute
      end
    end
    event = Event.order(:created_at).last
    assert_equal "Attempted to create assessment section, but failed: Name "\
    "can't be blank",
                 event.description
    assert_equal @user, event.user
    assert_equal @remote_ip, event.address
  end

  # object
  test 'object method should return the created AssessmentSection object' do
    assert_kind_of AssessmentSection, @command.object
  end

end
