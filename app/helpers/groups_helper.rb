module GroupsHelper
  def group_back_path(group)
    return menu_path(group.menu) if group.menu
    return groups_path
  end
end
 
