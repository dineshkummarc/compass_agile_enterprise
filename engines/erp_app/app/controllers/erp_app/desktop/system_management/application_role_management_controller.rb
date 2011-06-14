class ErpApp::Desktop::SystemManagement::ApplicationRoleManagementController < ErpApp::Desktop::BaseController
  def applications
    apps = Application.all

    node_hashes = []
    apps.each do |app|
      if !app.widgets.nil? && !app.widgets.empty?
        children_hashes = []
        app.widgets.each do |widget|
          children_hashes << {:text => widget.description, :is_leaf => true, :icon_cls => 'icon-document', :id => widget.id}
        end
        node_hashes << {:text => app.description, :icon_cls => app.icon, :id => app.id, :is_leaf => false, :children => children_hashes}
      end
    end
    render :inline => build_ext_tree(node_hashes)
  end

  def available_roles
    id = params[:id]
    widget = Widget.find(id)
    all_roles = Role.all
    current_role_ids = widget.roles.collect{|r| r.id}
    roles = all_roles.delete_if{|r| current_role_ids.include?(r.id)}

    render :inline => build_ext_tree(roles_to_node_hashes(roles))
  end

  def current_roles
    id = params[:id]
    widget = Widget.find(id)
    roles = widget.roles

    render :inline => build_ext_tree(roles_to_node_hashes(roles))
  end

  def save_roles
    id = params[:id]
    role_ids = params[:role_ids]

    widget = Widget.find(id)
    roles = Role.find(:all, :conditions => ["id in (#{role_ids.join(',')})"])
    widget.roles = roles
    widget.save

    render :inline => "{success:true,message:'Roles Saved'}"
  end

  private
  def roles_to_node_hashes(roles)
    node_hashes = []
    roles.each do |role|
      node_hashes << {:text => role.description, :is_leaf => true, :icon_cls => 'icon-user', :id => role.id}
    end

    node_hashes
  end
  
end