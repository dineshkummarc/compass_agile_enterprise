class SetupDefaultDesktopApps
  
  def self.up

    #create preference types
    desktop_backgroud_pt = PreferenceType.create(:description => 'Desktop Background', :internal_identifier => 'desktop_background')
    desktop_shortcut_pt = PreferenceType.create(:description => 'Desktop Shortcut', :internal_identifier => 'desktop_shortcut')
    auto_load_app_pt = PreferenceType.create(:description => 'Autoload Application', :internal_identifier => 'autoload_application')

    #create preference options
    yes_po = PreferenceOption.create(:description => 'Yes', :internal_identifier => 'yes', :value => 'yes')
    no_po = PreferenceOption.create(:description => 'No', :internal_identifier => 'no', :value => 'no')
    default_background_po = PreferenceOption.create(:description => 'Default Background', :internal_identifier => 'default_desktop_background', :value => 'desktop.gif')
    gradient_background_po = PreferenceOption.create(:description => 'Gradient Background', :internal_identifier => 'gradient_desktop_background', :value => 'gradient.png')

    #associate options
    desktop_shortcut_pt.preference_options << yes_po
    desktop_shortcut_pt.preference_options << no_po
    desktop_shortcut_pt.default_preference_option = no_po
    desktop_shortcut_pt.save
	
    auto_load_app_pt.preference_options << yes_po
    auto_load_app_pt.preference_options << no_po
    auto_load_app_pt.default_preference_option = no_po
    auto_load_app_pt.save
	
    desktop_backgroud_pt.preference_options << default_background_po
    desktop_backgroud_pt.preference_options << gradient_background_po
    desktop_backgroud_pt.default_preference_option = default_background_po
    desktop_backgroud_pt.save

    #create widgets and assign roles
    app_mgr = Widget.create(
      :description => 'Application Management',
      :icon => 'icon-user',
      :xtype => 'controlpanel_userapplicationmgtpanel',
      :internal_identifier => 'application_management'
    )

    app_mgr.roles << Role.iid('admin')
    app_mgr.save

    role_mgr = Widget.create(
      :description => 'Role Management',
      :icon => 'icon-user',
      :xtype => 'usermanagement_rolemanagementpanel',
      :internal_identifier => 'role_management'
    )

    role_mgr.roles << Role.iid('admin')
    role_mgr.save

    personal_info = Widget.create(
      :description => 'User Personal Info',
      :icon => 'icon-user',
      :xtype => 'usermanagement_personalinfopanel',
      :internal_identifier => 'user_personal_info'
    )

    personal_info.roles << Role.iid('admin')
    personal_info.roles << Role.iid('employee')
    personal_info.save

    #create application and assign widgets
    user_mgr_app = DesktopApplication.create(
      :description => 'User Management',
      :icon => 'icon-user',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.UserManagement',
      :internal_identifier => 'user_management',
      :shortcut_id => 'user-management-win'
    )

    desktop_shortcut_pt.preferenced_records << user_mgr_app
    auto_load_app_pt.preferenced_records << user_mgr_app
    user_mgr_app.widgets << role_mgr
    user_mgr_app.widgets << personal_info
    user_mgr_app.widgets << app_mgr
    user_mgr_app.save

    #created desktop app containers for users
    User.all.each do |user|
      desktop = Desktop.create
      desktop.user = user
      desktop_backgroud_pt.preferenced_records << desktop


      pref = Preference.create(
        :preference_type => desktop_backgroud_pt,
        :preference_option => default_background_po
      )

      desktop.user_preferences << UserPreference.create(
        :user => user,
        :preference => pref
      )

      setup_default_preferences_for_app(user, user_mgr_app, desktop_shortcut_pt, auto_load_app_pt, no_po)

      desktop.applications << user_mgr_app
      desktop.save
    end

    #system_management_app
    app_role_management = Widget.create(
      :description => 'Application Role Management',
      :icon => 'icon-document',
      :xtype => 'systemmanagement_applicationrolemanagment',
      :internal_identifier => 'application_role_management'
    )

    app_role_management.roles << Role.iid('admin')
    app_role_management.save

    system_management_app = DesktopApplication.create(
      :description => 'System Management',
      :icon => 'icon-monitor',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.SystemManagement',
      :internal_identifier => 'system_management',
      :shortcut_id => 'system_management-win'
    )

    desktop_shortcut_pt.preferenced_records << system_management_app
    auto_load_app_pt.preferenced_records << system_management_app
    system_management_app.widgets << app_role_management
    system_management_app.save
    
    rholmes = User.find_by_login('rholmes')
    setup_default_preferences_for_app(rholmes, system_management_app, desktop_shortcut_pt, auto_load_app_pt, no_po)
    rholmes.desktop.applications << system_management_app
    rholmes.desktop.save

    rkoloski = User.find_by_login('rkoloski')
    setup_default_preferences_for_app(rkoloski, system_management_app, desktop_shortcut_pt, auto_load_app_pt, no_po)
    rkoloski.desktop.applications << system_management_app
    rkoloski.desktop.save
  end
  
  def self.down
    UserPreference.destroy_all
    PreferenceType.destroy_all
	
    ['application_role_management','application_management', 'role_management', 'user_personal_info'].each do |iid|
      widget = Widget.find_by_internal_identifier(iid)
      widget.destroy unless widget.nil?
    end

    ['user_management', 'system_management'].each do |iid|
      app = DesktopApplication.find_by_internal_identifier(iid)
      app.destroy unless app.nil?
    end
	
    Desktop.destroy_all
  end

  private

  def self.setup_default_preferences_for_app(user, app, desktop_shortcut_pt, auto_load_app_pt, no_po)
    desktop_shortcut_pref = Preference.create(
      :preference_type => desktop_shortcut_pt,
      :preference_option => no_po
    )

    autoload_shortcut_pref = Preference.create(
      :preference_type => auto_load_app_pt,
      :preference_option => no_po
    )

    app.user_preferences << UserPreference.create(
      :user => user,
      :preference => desktop_shortcut_pref
    )

    app.user_preferences << UserPreference.create(
      :user => user,
      :preference => autoload_shortcut_pref
    )

    app.save
  end

end
