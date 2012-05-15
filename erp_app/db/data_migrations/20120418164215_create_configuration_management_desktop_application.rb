class CreateConfigurationManagementDesktopApplication
  def self.up
    app = DesktopApplication.create(
      :description => 'Configuration Management',
      :icon => 'icon-grid',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.ConfigurationManagement',
      :internal_identifier => 'configuration_management',
      :shortcut_id => 'configuration_management-win'
    )
    pt1 = PreferenceType.iid('desktop_shortcut')
    pt1.preferenced_records << app
    pt1.save

    pt2 = PreferenceType.iid('autoload_application')
    pt2.preferenced_records << app
    pt2.save
  end

  def self.down
    DesktopApplication.destroy_all(['internal_identifier = ?','configuration_management'])
  end
end
