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
          # move all of its children as well
          resource.all_children.each do |child|
            child.location = @location
            child.save!
          end
          # If the resource is a child resource and its parent is not in (or
          # being moved to) the same location, break its parent relationship
          resource.parent = nil if resource.parent and
              resource.parent.location != @location

          resource.save!
        end
      end
    rescue => e
      raise "Failed to move resource(s): #{e.message}"
    end
  end

  def object
    @location
  end

end
