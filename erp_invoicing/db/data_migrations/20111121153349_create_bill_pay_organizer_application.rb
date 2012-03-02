class CreateBillPayOrganizerApplication
  def self.up
    OrganizerApplication.create(
      :description => 'Bill Pay',
      :icon => 'icon-creditcards',
      :javascript_class_name => 'Compass.ErpApp.Organizer.Applications.BillPay.Base',
      :internal_identifier => 'bill_pay'
    )
  end

  def self.down
    OrganizerApplication.destroy_all(:conditions => ['internal_identifier = ?','bill_pay'])
  end
end
