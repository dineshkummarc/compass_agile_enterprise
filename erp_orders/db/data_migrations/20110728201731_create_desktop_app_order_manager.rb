class CreateDesktopAppOrderManager
  def self.up
    app = DesktopApplication.create(
      :description => 'Orders',
      :icon => 'icon-package',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.OrderManager',
      :internal_identifier => 'order_manager',
      :shortcut_id => 'order_manager-win'
    )
    
    pt = PreferenceType.iid('desktop_shortcut')
    pt.preferenced_records << app
    pt.save

    pt = PreferenceType.iid('autoload_application')
    pt.preferenced_records << app
    pt.save

    app.save
  end

  def self.down
    DesktopApplication.destroy_all(:conditions => ['internal_identifier = ?','hello_world'])
  end
end
