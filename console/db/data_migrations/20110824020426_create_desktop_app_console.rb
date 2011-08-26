class CreateDesktopAppConsole
  def self.up
    app = DesktopApplication.create(
      :description => 'Desktop Console',
      :icon => 'icon-console',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.Console',
      :internal_identifier => 'console',
      :shortcut_id => 'console-win'
    )
    
    app.preference_types << PreferenceType.iid('desktop_shortcut')
    app.preference_types << PreferenceType.iid('autoload_application')
    app.save
  end

  def self.down
    DesktopApplication.destroy_all(['internal_identifier = ?','console'])
  end
end
