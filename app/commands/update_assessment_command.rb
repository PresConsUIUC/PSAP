class UpdateAssessmentCommand < Command

  def initialize(assessment, assessment_params, user, remote_ip)
    @assessment = assessment
    @assessment_params = assessment_params
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    @assessment.update!(@assessment_params)
    Event.create(description: 'Updated assessment template',
                 user: @user, address: @remote_ip)
  end

  def object
    @assessment
  end

end
