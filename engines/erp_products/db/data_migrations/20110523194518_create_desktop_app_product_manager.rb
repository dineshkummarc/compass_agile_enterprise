class CreateDesktopAppProductManager
  def self.up
    app = DesktopApplication.create(
      :description => 'Products',
      :icon => 'icon-product',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.ProductManager',
      :internal_identifier => 'product_manager',
      :shortcut_id => 'product_manager-win'
    )
    
    PreferenceType.iid('desktop_shortcut').preferenced_records << app
    PreferenceType.iid('autoload_application').preferenced_records << app

    app.save
  end

  def self.down
    DesktopApplication.destroy_all(:conditions => ['internal_identifier = ?','hello_world'])
  end
end
