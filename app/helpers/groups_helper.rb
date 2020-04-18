module GroupsHelper
  def group_back_path(group)
    if group.menu
      edit_menu_path(group.menu.id)
    elsif(menu_id = params[:menu_id])
      edit_menu_path(menu_id)
    else
      return groups_path
    end
  end
end
