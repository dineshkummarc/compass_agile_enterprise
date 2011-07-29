class AddNotesWidget
  
  def self.up
    if(::Widget.find_by_internal_identifier('user_management_notes_grid').nil?)
      #create basic Note Type
      NoteType.create(:description => 'Basic Note', :internal_identifier => 'basic_note')

      notes_grid = ::Widget.create(
        :description => 'Notes',
        :icon => 'icon-documents',
        :xtype => 'shared_notesgrid',
        :internal_identifier => 'shared_notes_grid'
      )

      notes_grid.roles << Role.iid('admin')
      notes_grid.roles << Role.iid('employee')
      notes_grid.save

      user_mgr_app = DesktopApplication.find_by_internal_identifier('user_management')
      user_mgr_app.widgets << notes_grid
      user_mgr_app.save

      crm_app = OrganizerApplication.find_by_internal_identifier('crm')
      crm_app.widgets << notes_grid
      crm_app.save
    end
  end
  
  def self.down
    #remove data here
  end

end
