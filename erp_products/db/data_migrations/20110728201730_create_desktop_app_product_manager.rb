class CreateDesktopAppProductManager
  def self.up
    app = DesktopApplication.create(
      :description => 'Products',
      :icon => 'icon-product',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.ProductManager',
      :internal_identifier => 'product_manager',
      :shortcut_id => 'product_manager-win'
    )

    pt1 = PreferenceType.iid('desktop_shortcut')
    pt1.preferenced_records << app
    pt1.save

    pt2 = PreferenceType.iid('autoload_application')
    pt2.preferenced_records << app
    pt2.save

    app.save
  end

  def self.down
    DesktopApplication.destroy_all(:conditions => ['internal_identifier = ?','hello_world'])
  end
end
