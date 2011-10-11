class CreateDesktopAppConsole
  def self.up
    app = DesktopApplication.create(
      :description => 'Desktop Console',
      :icon => 'icon-console',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.Console',
      :internal_identifier => 'console',
      :shortcut_id => 'console-win'
    )
    
    #PreferenceType.iid('desktop_shortcut').preferenced_records << app
    #PreferenceType.iid('autoload_application').preferenced_records << app

    app.save
  end

  def self.down
    DesktopApplication.destroy_all(['internal_identifier = ?','console'])
  end
end
