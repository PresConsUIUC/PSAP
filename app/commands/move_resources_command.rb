##
# Moves one or more resources to a new location.
#
class MoveResourcesCommand < Command

  def initialize(resources, location, doing_user, remote_ip)
    @resources = resources
    @location = location
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      # Fail if the user is not an admin AND any of the source resources or
      # destination location are outside the user's institution
      if !@doing_user.is_admin? and
          (@resources.select{ |r| r.location.repository.institution != @doing_user.institution }.any? or
          @location.repository.institution != @doing_user.institution )
        raise 'Insufficient privileges'
      end

      raise 'No resources to move' unless @resources.any?
      raise 'No location provided' unless @location

      ActiveRecord::Base.transaction do
        @resources.each do |resource|
          resource.location = @location
          resource.save!
          # move all of its children as well
          resource.all_children.each do |child|
            child.location = @location
            child.save!
          end
        end

        # Fail if the resource is a child resource and its parent is not in (or
        # being moved to) the same location
        if @resources.select{
            |r| r.parent and r.parent.location.id != @location.id }.any?
          raise 'Cannot move a child resource to a different location than its '\
          'parent'
        end
      end
    rescue => e
      Event.create(
          description: "Attempted to move resources, but failed: #{e.message}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::ERROR)
      raise "Failed to move resource(s): #{e.message}"
    else
      @resources.each do |resource|
        event = Event.create(
            description: "Moved resource to #{@location.name}",
            user: @doing_user, address: @remote_ip)
        resource.events << event
        @location.events << event
      end
    end
  end

  def object
    @location
  end

end
