class ErpApp::Desktop::UserManagement::RoleManagementController < ErpApp::Desktop::UserManagement::BaseController

  def available_roles
    user_id = params[:user_id]

    roles = Role.all
    current_role_ids = User.find(user_id).roles.collect{|r| r.id}
    roles.delete_if{|r| current_role_ids.include?(r.id)}

    render :inline => build_ext_tree(roles_to_node_hashes(roles))
  end

  def current_roles
    user_id = params[:user_id]
    
    roles = User.find(user_id).roles

    render :inline => build_ext_tree(roles_to_node_hashes(roles))
  end

  def save_roles
    role_ids = params[:role_ids]
    user_id  = params[:user_id]
    roles = []

    user = User.find(user_id)
    roles = Role.find(:all, :conditions => ["id in (#{role_ids.join(',')})"])
    user.roles = roles
    user.save

    render :inline => "{success:true,message:'Roles Saved'}"
  end

  private

  def roles_to_node_hashes(roles)
    node_hashes = []
    roles.each do |role|
      node_hashes << {:text => role.description, :icon_cls => 'icon-user', :is_leaf => true, :attributes => {:role_id => role.id}}
    end

    node_hashes
  end
end
