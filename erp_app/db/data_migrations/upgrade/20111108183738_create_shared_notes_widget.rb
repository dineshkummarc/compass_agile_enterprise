class CreateSharedNotesWidget
  
  def self.up
    if ::Widget.find_by_internal_identifier('shared_notes_grid').nil?
      NoteType.create(:description => 'Basic Note', :internal_identifier => 'basic_note')

      notes_grid = ::Widget.create(
        :description => 'Notes',
        :icon => 'icon-documents',
        :xtype => 'shared_notesgrid',
        :internal_identifier => 'shared_notes_grid'
      )

      notes_grid.add_role('admin')
      notes_grid.add_role('employee')
      notes_grid.save

      user_mgr_app = DesktopApplication.find_by_internal_identifier('user_management')
      user_mgr_app.widgets << notes_grid
      user_mgr_app.save
    end
  end
  
  def self.down
    #remove data here
  end

end
