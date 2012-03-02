class CreateInvoiceManagementDesktopApplication
  def self.up
    app = DesktopApplication.create(
      :description => 'Invoice Management',
      :icon => 'icon-creditcards',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.InvoiceManagement',
      :internal_identifier => 'invoice_management',
      :shortcut_id => 'invoice_management-win'
    )

    app.save

    pt1 = PreferenceType.iid('desktop_shortcut')
    pt1.preferenced_records << app
    pt1.save

    pt2 = PreferenceType.iid('autoload_application')
    pt2.preferenced_records << app
    pt2.save
    
  end

  def self.down
    DesktopApplication.destroy_all(['internal_identifier = ?','invoice_management'])
  end
end
