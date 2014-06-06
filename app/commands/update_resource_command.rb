class UpdateResourceCommand < Command

  def initialize(resource, resource_params, doing_user, remote_ip)
    @resource = resource
    @resource_params = resource_params
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      # nested AQRs require some additional processing in order to update
      # existing resource AQRs; otherwise they would be added as duplicates
      if @resource_params[:assessment_question_responses_attributes]
        @resource_params[:assessment_question_responses_attributes].each do |key, value|
          responses = @resource.assessment_question_responses.select{ |r|
            r.id == key.to_i }
          responses.map{ |response|
            response.assessment_question_id = value[:assessment_question_id]
            response.assessment_question_option_id = value[:assessment_question_option_id] }
        end
      end

      update_params = @resource_params.except('assessment_question_responses_attributes')
      @resource.update!(update_params)
    rescue ActiveRecord::RecordInvalid
      @resource.events << Event.create(
          description: "Attempted to update resource \"#{@resource.name},\" "\
          "but failed: #{@resource.errors.full_messages[0]}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::DEBUG)
      raise ValidationError,
            "Failed to update resource \"#{@resource.name}\": "\
            "#{@resource.errors.full_messages[0]}"
    rescue => e
      @resource.events << Event.create(
          description: "Failed to update resource "\
          "\"#{@resource.name},\" but failed:: #{e.message}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::ERROR)
      raise "Failed to update resource \"#{@resource.name}\": #{e.message}"
    else
      @resource.events << Event.create(
          description: "Updated resource \"#{@resource.name}\" in "\
          "location \"#{@resource.location.name}\"",
          user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @resource
  end

end
