class SetupDefaultOrganizerApps
  
  def self.up
    party_contact_mgm_widget = Widget.create(
      :description => 'Party Contact Management',
      :icon => 'icon-grid',
      :xtype => 'contactmechanismgrid',
      :internal_identifier => 'party_contact_management'
    )

    party_contact_mgm_widget.roles << Role.iid('admin')
    party_contact_mgm_widget.roles << Role.iid('employee')
    party_contact_mgm_widget.save

    party_mgm_widget = Widget.create(
      :description => 'Party Management',
      :icon => 'icon-grid',
      :xtype => 'partygrid',
      :internal_identifier => 'party_management_widget'
    )

    party_mgm_widget.roles << Role.iid('admin')
    party_mgm_widget.roles << Role.iid('employee')
    party_mgm_widget.save

    #create application
    crm_app = OrganizerApplication.create(
      :description => 'CRM',
      :icon => 'icon-user',
      :internal_identifier => 'crm'
    )

    crm_app.widgets << party_contact_mgm_widget
    crm_app.widgets << party_mgm_widget
    crm_app.save

    #created desktop app containers for users
    User.all.each do |user|
      organizer = Organizer.create
      organizer.user = user
     
      organizer.applications << crm_app
      organizer.save
    end
  end
  
  def self.down
    ['party_management_widget','party_contact_management'].each do |iid|
      widget = Widget.find_by_internal_identifier(iid)
      widget.destroy unless widget.nil?
    end

    app = OrganizerApplication.find_by_internal_identifier('crm')
    app.destroy unless app.nil?

    Organizer.destroy_all
  end

end
