module RolesHelper

  def human_readable_permissions_for_role(role)
    if role.permissions.empty?
      return '(none)'
    else
      permission_names = []
      role.permissions.each do |p|
        permission_names << p.key
      end
      names = permission_names.join(', ')
      return names
    end
  end

end
