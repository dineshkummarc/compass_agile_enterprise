class ErpApp::Setup::Data
  def self.run_setup
    #######################################
    #parties
    #######################################

    #Admins
    Individual.create(:current_first_name => 'Admin',:current_last_name => 'Istrator',:gender => 'm')

    #Organization
    Organization.create(:description => 'TrueNorth')

    #######################################
    #contact purposes
    #######################################
    [
      {:description => 'Default', :internal_identifier => 'default'},
      {:description => 'Home', :internal_identifier => 'home'},
      {:description => 'Work', :internal_identifier => 'work'},
      {:description => 'Billing', :internal_identifier => 'billing'},
      {:description => 'Temporary', :internal_identifier => 'temporary'},
      {:description => 'Tax Reporting', :internal_identifier => 'tax_reporting'},
      {:description => 'Recruiting', :internal_identifier => 'recruiting'},
      {:description => 'Employment Offer', :internal_identifier => 'employment_offer'},
      {:description => 'Business', :internal_identifier => 'business'},
      {:description => 'Personal', :internal_identifier => 'personal'},
      {:description => 'Fax', :internal_identifier => 'fax'},
      {:description => 'Mobile', :internal_identifier => 'mobile'},
      {:description => 'Emergency', :internal_identifier => 'emergency'},
      {:description => 'Shipping', :internal_identifier => 'shipping'},
      {:description => 'Other', :internal_identifier => 'other'},
    ].each do |item|
      contact_purpose = ContactPurpose.find_by_internal_identifier(item[:internal_identifier])
      ContactPurpose.create(:description => item[:description], :internal_identifier => item[:internal_identifier]) if contact_purpose.nil?
    end

    #######################################
    #roles
    #######################################
    Role.create(:description => 'Admin', :internal_identifier => 'admin')
    Role.create(:description => 'Employee', :internal_identifier => 'employee')

    #######################################
    #users
    #######################################
    root_individual= Individual.find(:first, :conditions => ['current_first_name = ?',"Admin"])
    root_user=User.create(
      :login => "admin",
      :email => "admin@portablemind.com"
    )
    root_user.password = 'password'
    root_user.password_confirmation = 'password'
    root_user.activated_at = Time.now
    root_user.enabled = true
    root_user.party = root_individual.party
    root_user.save
    root_user.roles << Role.iid('admin')
    root_user.save

    ['TrueNorth'].each do |name|
      organization = Organization.find(:first, :conditions => ['description = ?', name])
      user = User.create(
        :login => organization.description.downcase,
        :email => "#{organization.description.downcase}@gmail.com"
      )
      user.password = 'password'
      user.password_confirmation = 'password'
      user.activated_at = Time.now
      user.enabled = true
      user.party = organization.party
      user.save
      user.roles << Role.iid('admin')
      user.save
    end

    #######################################
    #desktop setup
    #######################################
    #create preference types
    desktop_backgroud_pt = PreferenceType.create(:description => 'Desktop Background', :internal_identifier => 'desktop_background')
    desktop_shortcut_pt = PreferenceType.create(:description => 'Desktop Shortcut', :internal_identifier => 'desktop_shortcut')
    auto_load_app_pt = PreferenceType.create(:description => 'Autoload Application', :internal_identifier => 'autoload_application')

    #create preference options
    yes_po = PreferenceOption.create(:description => 'Yes', :internal_identifier => 'yes', :value => 'yes')
    no_po = PreferenceOption.create(:description => 'No', :internal_identifier => 'no', :value => 'no')
    blue_background_po = PreferenceOption.create(:description => 'Blue', :internal_identifier => 'blue_desktop_background', :value => 'blue.gif')
    gradient_background_po = PreferenceOption.create(:description => 'Grey Gradient', :internal_identifier => 'grey_gradient_desktop_background', :value => 'gradient.png')
    purple_background_po = PreferenceOption.create(:description => 'Purple', :internal_identifier => 'purple_desktop_background', :value => 'purple.jpg')
    planet_background_po = PreferenceOption.create(:description => 'Planet', :internal_identifier => 'purple_desktop_background', :value => 'planet.jpg')
    portablemind_background_po = PreferenceOption.create(:description => 'Portablemind', :internal_identifier => 'portablemind_desktop_background', :value => 'portablemind.png')


    #associate options
    desktop_shortcut_pt.preference_options << yes_po
    desktop_shortcut_pt.preference_options << no_po
    desktop_shortcut_pt.default_preference_option = no_po
    desktop_shortcut_pt.save

    auto_load_app_pt.preference_options << yes_po
    auto_load_app_pt.preference_options << no_po
    auto_load_app_pt.default_preference_option = no_po
    auto_load_app_pt.save

    desktop_backgroud_pt.preference_options << blue_background_po
    desktop_backgroud_pt.preference_options << gradient_background_po
    desktop_backgroud_pt.preference_options << purple_background_po
    desktop_backgroud_pt.preference_options << planet_background_po
    desktop_backgroud_pt.preference_options << portablemind_background_po
    desktop_backgroud_pt.default_preference_option = portablemind_background_po
    desktop_backgroud_pt.save

    #create widgets and assign roles
    app_mgr = ::Widget.create(
      :description => 'Application Management',
      :icon => 'icon-user',
      :xtype => 'controlpanel_userapplicationmgtpanel',
      :internal_identifier => 'application_management'
    )

    app_mgr.roles << Role.iid('admin')
    app_mgr.save

    role_mgr = ::Widget.create(
      :description => 'Role Management',
      :icon => 'icon-user',
      :xtype => 'usermanagement_rolemanagementpanel',
      :internal_identifier => 'role_management'
    )

    role_mgr.roles << Role.iid('admin')
    role_mgr.save

    personal_info = ::Widget.create(
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
        :preference_option => portablemind_background_po
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
    app_role_management = ::Widget.create(
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

    admin = User.find_by_login('admin')
    setup_default_preferences_for_app(admin, system_management_app, desktop_shortcut_pt, auto_load_app_pt, no_po)
    admin.desktop.applications << system_management_app
    admin.desktop.save

    #######################################
    #organizer setup
    #######################################
    party_contact_mgm_widget = ::Widget.create(
      :description => 'Party Contact Management',
      :icon => 'icon-grid',
      :xtype => 'contactmechanismgrid',
      :internal_identifier => 'party_contact_management'
    )

    party_contact_mgm_widget.roles << Role.iid('admin')
    party_contact_mgm_widget.roles << Role.iid('employee')
    party_contact_mgm_widget.save

    party_mgm_widget = ::Widget.create(
      :description => 'Party Management',
      :icon => 'icon-grid',
      :xtype => 'partygrid',
      :internal_identifier => 'party_management_widget'
    )

    party_mgm_widget.roles << Role.iid('admin')
    party_mgm_widget.roles << Role.iid('employee')
    party_mgm_widget.save

    #create application
    crm_app = OrganizerApplication.create(
      :description => 'CRM',
      :icon => 'icon-user',
      :internal_identifier => 'crm'
    )

    crm_app.widgets << party_contact_mgm_widget
    crm_app.widgets << party_mgm_widget
    crm_app.save

    User.all.each do |user|
      organizer = Organizer.create
      organizer.user = user

      organizer.applications << crm_app
      organizer.save
    end

    #######################################
    #file manager app
    #######################################
    file_manager_app = DesktopApplication.create(
      :description => 'File Manager',
      :icon => 'icon-folders',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.FileManager',
      :internal_identifier => 'file_manager',
      :shortcut_id => 'file_manager-win'
    )

    PreferenceType.iid('desktop_shortcut').preferenced_records << file_manager_app
    PreferenceType.iid('autoload_application').preferenced_records << file_manager_app

    file_manager_app.save

    admin = User.find_by_login('admin')
    setup_default_preferences_for_app(admin, file_manager_app, desktop_shortcut_pt, auto_load_app_pt, no_po)
    admin.desktop.applications << file_manager_app
    admin.desktop.save

    #######################################
    #scaffold app
    #######################################
    scaffold_app = DesktopApplication.create(
      :description => 'Scaffold',
      :icon => 'icon-data',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.Scaffold',
      :internal_identifier => 'scaffold',
      :shortcut_id => 'scaffold-win'
    )

    PreferenceType.iid('desktop_shortcut').preferenced_records << scaffold_app
    PreferenceType.iid('autoload_application').preferenced_records << scaffold_app

    scaffold_app.save

    admin = User.find_by_login('admin')
    setup_default_preferences_for_app(admin, scaffold_app, desktop_shortcut_pt, auto_load_app_pt, no_po)
    admin.desktop.applications << scaffold_app
    admin.desktop.save

    #######################################
    #knitkit app
    #######################################
    knikit_app = DesktopApplication.create(
      :description => 'KnitKit',
      :icon => 'icon-palette',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.Knitkit',
      :internal_identifier => 'knitkit',
      :shortcut_id => 'knitkit-win'
    )

    PreferenceType.iid('desktop_shortcut').preferenced_records << knikit_app
    PreferenceType.iid('autoload_application').preferenced_records << knikit_app

    knikit_app.save

    admin = User.find_by_login('admin')
    setup_default_preferences_for_app(admin, knikit_app, desktop_shortcut_pt, auto_load_app_pt, no_po)
    admin.desktop.applications << knikit_app
    admin.desktop.save

    Role.create(:internal_identifier => 'publisher', :description => 'Publisher')

    #######################################
    #rails_db_admin app
    #######################################
    rails_db_admin_app = DesktopApplication.create(
      :description => 'RailsDbAdmin',
      :icon => 'icon-rails_db_admin',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.RailsDbAdmin',
      :internal_identifier => 'rails_db_admin',
      :shortcut_id => 'rails_db_admin-win'
    )

    PreferenceType.iid('desktop_shortcut').preferenced_records << rails_db_admin_app
    PreferenceType.iid('autoload_application').preferenced_records << rails_db_admin_app

    rails_db_admin_app.save

    admin = User.find_by_login('admin')
    setup_default_preferences_for_app(admin, rails_db_admin_app, desktop_shortcut_pt, auto_load_app_pt, no_po)
    admin.desktop.applications << rails_db_admin_app
    admin.desktop.save
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
