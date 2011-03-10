class ErpApp::Desktop::UserManagement::BaseController < ErpApp::Desktop::BaseController

  before_filter :get_user, :only => [:get_details, :delete]

  def index
    User.include_root_in_json = false
    login = params[:login]

    if login.blank?
      users = User.all
    else
      users = User.find(:all, :conditions => ['login like ?', "%#{login}%"])
    end

    ext_json = "{data:#{users.to_json(:only => [:id, :login, :email])}}"

    render :inline => ext_json
  end

  def get_details
    entity_info = nil
    if @user.party.business_party.is_a?(Individual)
      entity_info = @user.party.business_party.to_json(:only => [:current_first_name, :current_last_name, :gender, :total_years_work_experience])
    else
      entity_info = @user.party.business_party.to_json(:only => [:description])
    end

    ext_json = "{entityType:'#{@user.party.business_party.class.to_s}', entityInfo:#{entity_info}}"

    render :inline => ext_json
  end

  def new
    response = {}

    ignored_params = %w{action controller gender}

    options = params
    gender = options[:gender]
    options.delete_if{|k,v| ignored_params.include?(k.to_s)}
    user = User.create(options)
    
    if user.valid?
      user.activated_at = Time.now
      user.save
      user.party.business_party.gender = gender
      user.party.business_party.save
      response = {:success => true}
    else
      message = "<ul>"
      user.errors.collect do |e, m|
        message << "<li>#{e.humanize unless e == "base"} #{m}</li>"
      end
      message << "</ul>"
      response = {:success => false, :message => message}
    end

    render :inline => response.to_json
  end

  def delete
    unless @user.party.nil?
      @user.party.destroy
    else
      @user.destroy
    end
    
    render :inline => {:success => true}.to_json
  end

  private

  def get_user
    @user = User.find(params[:id])
  end

end
