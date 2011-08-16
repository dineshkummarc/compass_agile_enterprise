class ErpAppSetup
  
  def self.up
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
    #desktop setup
    #######################################
    #create preference types
    desktop_backgroud_pt = PreferenceType.create(:description => 'Desktop Background', :internal_identifier => 'desktop_background')
    extjs_theme_pt       = PreferenceType.create(:description => 'Theme', :internal_identifier => 'extjs_theme')
    desktop_shortcut_pt  = PreferenceType.create(:description => 'Desktop Shortcut', :internal_identifier => 'desktop_shortcut')
    auto_load_app_pt     = PreferenceType.create(:description => 'Autoload Application', :internal_identifier => 'autoload_application')

    #create preference options
    #yes no options
    yes_po = PreferenceOption.create(:description => 'Yes', :internal_identifier => 'yes', :value => 'yes')
    no_po  = PreferenceOption.create(:description => 'No', :internal_identifier => 'no', :value => 'no')

    #desktop background options
    blue_background_po         = PreferenceOption.create(:description => 'Blue', :internal_identifier => 'blue_desktop_background', :value => 'blue.gif')
    gradient_background_po     = PreferenceOption.create(:description => 'Grey Gradient', :internal_identifier => 'grey_gradient_desktop_background', :value => 'gradient.png')
    purple_background_po       = PreferenceOption.create(:description => 'Purple', :internal_identifier => 'purple_desktop_background', :value => 'purple.jpg')
    planet_background_po       = PreferenceOption.create(:description => 'Planet', :internal_identifier => 'purple_desktop_background', :value => 'planet.jpg')
    portablemind_background_po = PreferenceOption.create(:description => 'Portablemind', :internal_identifier => 'portablemind_desktop_background', :value => 'portablemind.png')

    #desktop theme options
    access_extjs_theme_po = PreferenceOption.create(:description => 'Access', :internal_identifier => 'access_extjs_theme', :value => 'ext-all-access.css')
    gray_extjs_theme_po   = PreferenceOption.create(:description => 'Gray', :internal_identifier => 'gray_extjs_theme', :value => 'ext-all-gray.css')
    blue_extjs_theme_po   = PreferenceOption.create(:description => 'Blue', :internal_identifier => 'blue_extjs_theme', :value => 'ext-all.css')

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

    extjs_theme_pt.preference_options << access_extjs_theme_po
    extjs_theme_pt.preference_options << gray_extjs_theme_po
    extjs_theme_pt.preference_options << blue_extjs_theme_po
    extjs_theme_pt.default_preference_option = blue_extjs_theme_po
    extjs_theme_pt.save
    
    #######################################
    #notes widget
    #######################################
    NoteType.create(:description => 'Basic Note', :internal_identifier => 'basic_note')
    
    notes_grid = ::Widget.create(
      :description => 'Notes',
      :icon => 'icon-documents',
      :xtype => 'shared_notesgrid',
      :internal_identifier => 'shared_notes_grid'
    )

    notes_grid.roles << Role.iid('admin')
    notes_grid.roles << Role.iid('employee')
    notes_grid.save
    
    #######################################
    #user management app
    #######################################
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

    user_mgr_app.preference_types << desktop_shortcut_pt
    user_mgr_app.preference_types << auto_load_app_pt
    
    user_mgr_app.widgets << role_mgr
    user_mgr_app.widgets << personal_info
    user_mgr_app.widgets << app_mgr
    user_mgr_app.widgets << notes_grid
    user_mgr_app.save
    
    #######################################
    #system management app
    #######################################
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

    system_management_app.preference_types << desktop_shortcut_pt
    system_management_app.preference_types << auto_load_app_pt

    system_management_app.widgets << app_role_management
    system_management_app.save
    
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

    file_manager_app.preference_types << PreferenceType.iid('desktop_shortcut')
    file_manager_app.preference_types << PreferenceType.iid('autoload_application')
    file_manager_app.save

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

    scaffold_app.preference_types << PreferenceType.iid('desktop_shortcut')
    scaffold_app.preference_types << PreferenceType.iid('autoload_application')
    scaffold_app.save
    
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
    crm_app.widgets << notes_grid
    crm_app.save
    
    #######################################
    #parties
    #######################################

    #Admins
    Individual.create(:current_first_name => 'Admin',:current_last_name => 'Istrator',:gender => 'm')

    #Organization
    Organization.create(:description => 'TrueNorth')
    
    #######################################
    #users
    #######################################
    admin_indvidual = Individual.find(:first, :conditions => ['current_first_name = ?',"Admin"])
    admin_user = User.create(
      :login => "admin",
      :email => "admin@portablemind.com"
    )
    admin_user.password = 'password'
    admin_user.password_confirmation = 'password'
    admin_user.activated_at = Time.now
    admin_user.enabled = true
    admin_user.party = admin_indvidual.party
    admin_user.save
    admin_user.roles << Role.iid('admin')
    admin_user.save

    truenorth = Organization.find(:first, :conditions => ['description = ?', 'TrueNorth'])
    truenorth_user = User.create(
      :login => truenorth.description.downcase,
      :email => "#{truenorth.description.downcase}@gmail.com"
    )
    truenorth_user.password = 'password'
    truenorth_user.password_confirmation = 'password'
    truenorth_user.activated_at = Time.now
    truenorth_user.enabled = true
    truenorth_user.party = truenorth.party
    truenorth_user.save
    truenorth_user.roles << Role.iid('admin')
    truenorth_user.save
    
    admin_user.desktop.applications << user_mgr_app
    admin_user.desktop.applications << system_management_app
    admin_user.desktop.applications << file_manager_app
    admin_user.desktop.applications << scaffold_app
    admin_user.desktop.save
    admin_user.organizer.applications << crm_app
    admin_user.organizer.save
    
    truenorth_user.desktop.applications << user_mgr_app
    truenorth_user.desktop.applications << system_management_app
    truenorth_user.desktop.applications << file_manager_app
    truenorth_user.desktop.applications << scaffold_app
    truenorth_user.desktop.save
    truenorth_user.organizer.applications << crm_app
    truenorth_user.organizer.save
    
  end
  
  def self.down
    #remove data here
  end

end
