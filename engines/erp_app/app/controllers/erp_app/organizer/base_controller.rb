class ErpApp::Organizer::BaseController < ErpApp::ApplicationController
  before_filter :login_required
  
  def login_path
    return organizer_login_path
  end

  def index
    @organizer = ::Organizer.find_by_user(current_user)
    @user = current_user
  end

  #organizer user preferences

  def get_preferences
    user = current_user
    organizer = ::Organizer.find_by_user(user)
    preferences = organizer.preferences

    ext_json = "{success:true, preferences:#{preferences.to_json(:include => [:preference_type, :preference_option])}}"

    render :inline => ext_json
  end

  def setup_preferences
    PreferenceType.include_root_in_json = false
    PreferenceOption.include_root_in_json = false

    user = current_user
    ext_json = '{success:true,preference_types:'

    organizer = ::Organizer.find_by_user(user)
    preference_types = organizer.preference_types
    ext_json << preference_types.to_json(:include => :preference_options)
    ext_json << "}"
    render :inline => ext_json
  end

  def update_preferences
    user = current_user
    organizer = ::Organizer.find_by_user(user)

    params.each do |k,v|
      organizer.set_preference(k, v) unless k.to_s == 'action' or k.to_s == 'controller'
    end

    organizer.save

    preferences = organizer.preferences

    ext_json = "{success:true, preferences:#{preferences.to_json(:include => [:preference_type, :preference_option])}}"

    render :inline => ext_json
  end
end
