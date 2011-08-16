class AddKnitkitApplication
  
  def self.up
    knikit_app = DesktopApplication.create(
      :description => 'KnitKit',
      :icon => 'icon-palette',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.Knitkit',
      :internal_identifier => 'knitkit',
      :shortcut_id => 'knitkit-win'
    )

    knikit_app.preference_types << PreferenceType.iid('desktop_shortcut')
    knikit_app.preference_types << PreferenceType.iid('autoload_application')
    knikit_app.save
    
    admin_user = User.find_by_login('admin')
    admin_user.desktop.applications << knikit_app
    admin_user.save
    
    truenorth_user = User.find_by_login('truenorth')
    truenorth_user.desktop.applications << knikit_app
    truenorth_user.save
  end
  
  def self.down
    DesktopApplication.find_by_internal_identifier('knitkit').destroy
  end

end
