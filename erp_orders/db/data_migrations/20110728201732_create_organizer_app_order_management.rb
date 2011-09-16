class CreateOrganizerAppOrderManagement
  def self.up
    OrganizerApplication.create(
      :description => 'Orders',
      :icon => 'icon-package',
      :javascript_class_name => 'Compass.ErpApp.Organizer.Applications.OrderManagement.Base',
      :internal_identifier => 'order_management'
    )
  end

  def self.down
    OrganizerApplication.destroy_all(:conditions => ['internal_identifier = ?','order_management'])
  end
end
