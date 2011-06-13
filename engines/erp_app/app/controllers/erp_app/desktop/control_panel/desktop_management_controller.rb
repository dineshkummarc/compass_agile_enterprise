class ErpApp::Desktop::ControlPanel::DesktopManagementController < ErpApp::ApplicationController

  def desktop_preferences
    PreferenceType.include_root_in_json = false
    PreferenceOption.include_root_in_json = false

    user = current_user
    ext_json = '{success:true,preference_types:'

    desktop = ::Desktop.find_by_user(user)
    preference_types = desktop.preference_types
    ext_json << preference_types.to_json(:include => :preference_options)
    ext_json << "}"
    render :inline => ext_json
  end

  def selected_desktop_preferences
    ::Desktop.include_root_in_json = false

    user = current_user
    desktop = ::Desktop.find_by_user(user)
    preferences = desktop.preferences

    ext_json = "{success:true, preferences:#{preferences.to_json(:include => [:preference_type, :preference_option])}}"

    render :inline => ext_json
  end

  def update_desktop_preferences
    user = current_user
    desktop = ::Desktop.find_by_user(user)

    params.each do |k,v|
      desktop.set_preference(k, v) unless k.to_s == 'action' or k.to_s == 'controller'
    end
    
    desktop.save

    preferences = desktop.preferences

    ext_json = "{success:true, preferences:#{preferences.to_json(:include => [:preference_type, :preference_option])}}"
    
    render :inline => ext_json
  end

  def add_background
    result = ::Desktop.add_background(params[:description], params[:image_data])

    render :inline => result.to_json
  end

end
