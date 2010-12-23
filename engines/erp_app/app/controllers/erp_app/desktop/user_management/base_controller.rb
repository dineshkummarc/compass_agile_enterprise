class ErpApp::Desktop::UserManagement::BaseController < ErpApp::Desktop::BaseController

  def index
    User.include_root_in_json = false
    login = params[:login]

    if login.blank?
      users = User.all
    else
      users = User.find(:all, :conditions => ['login like ?', "%#{login}%"])
    end

    ext_json = "{data:#{users.to_json(:only => [:id, :login, :email, :enabled])}}"

    render :inline => ext_json
  end

  def get_details
    user_id = params[:id]

    user = User.find(user_id)

    entity_info = nil
    if user.party.business_party.is_a?(Individual)
      entity_info = user.party.business_party.to_json(:only => [:current_first_name, :current_last_name, :gender, :total_years_work_experience])
    else
      entity_info = user.party.business_party.to_json(:only => [:description])
    end

    ext_json = "{entityType:'#{user.party.business_party.class.to_s}', entityInfo:#{entity_info}}"

    render :inline => ext_json
  end
end
