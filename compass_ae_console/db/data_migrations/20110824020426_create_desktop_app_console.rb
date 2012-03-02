class CreateDesktopAppConsole
  def self.up
    app = DesktopApplication.create(
      :description => 'Compass Console',
      :icon => 'icon-console',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.CompassAeConsole',
      :internal_identifier => 'compass_ae_console',
      :shortcut_id => 'compass_console-win'
    )
    
    app.preference_types << PreferenceType.iid('desktop_shortcut')
    app.preference_types << PreferenceType.iid('autoload_application')
    app.save
  end

  def self.down
    DesktopApplication.destroy_all(['internal_identifier = ?','compass_ae_console'])
  end
end
