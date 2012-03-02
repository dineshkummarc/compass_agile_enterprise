class SetupKnitkitCapabilities
  
  def self.up
    Role.create(:internal_identifier => 'content_author', :description => 'Content Author') unless Role.find_by_internal_identifier("content_author")
    Role.create(:internal_identifier => 'layout_author', :description => 'Layout Author') unless Role.find_by_internal_identifier("layout_author")
    Role.create(:internal_identifier => 'editor', :description => 'Editor') unless Role.find_by_internal_identifier("editor")
    Role.create(:internal_identifier => 'designer', :description => 'Designer') unless Role.find_by_internal_identifier("designer")
    Role.create(:internal_identifier => 'website_author', :description => 'Website Author') unless Role.find_by_internal_identifier("website_author")
    
    CapabilityType.create(:internal_identifier => 'import', :description => 'Import')
    CapabilityType.create(:internal_identifier => 'publish', :description => 'Publish')
    CapabilityType.create(:internal_identifier => 'activate', :description => 'Activate')
    CapabilityType.create(:internal_identifier => 'secure', :description => 'Secure')
    CapabilityType.create(:internal_identifier => 'unsecure', :description => 'Unsecure')
    CapabilityType.create(:internal_identifier => 'revert_version', :description => 'Revert Version')
    CapabilityType.create(:internal_identifier => 'add_existing', :description => 'Add Existing')
    CapabilityType.create(:internal_identifier => 'upload', :description => 'Upload')
    CapabilityType.create(:internal_identifier => 'edit_html', :description => 'Edit Html')
    CapabilityType.create(:internal_identifier => 'edit_excerpt', :description => 'Edit Excerpt')
    CapabilityType.create(:internal_identifier => 'drag_item', :description => 'Drag Item')

    knitkit_application = DesktopApplication.find_by_internal_identifier('knitkit')
    knitkit_application.add_capability('create', 'Menu', 'admin', 'website_author')
    knitkit_application.add_capability('delete', 'Menu', 'admin', 'website_author')
    knitkit_application.add_capability('edit', 'Menu', 'admin', 'website_author')

    knitkit_application.add_capability('create', 'Website', 'admin', 'website_author')
    knitkit_application.add_capability('delete', 'Website', 'admin', 'website_author')
    knitkit_application.add_capability('edit', 'Website', 'admin', 'website_author')
    knitkit_application.add_capability('import', 'Website', 'admin', 'website_author')
    knitkit_application.add_capability('publish', 'Website', 'admin', 'publisher')
    knitkit_application.add_capability('activate', 'Website', 'admin', 'publisher')

    knitkit_application.add_capability('create', 'Host', 'admin', 'website_author')
    knitkit_application.add_capability('delete', 'Host', 'admin', 'website_author')
    knitkit_application.add_capability('edit', 'Host', 'admin', 'website_author')

    knitkit_application.add_capability('create', 'Section', 'admin', 'website_author')
    knitkit_application.add_capability('delete', 'Section', 'admin', 'website_author')
    knitkit_application.add_capability('edit', 'Section', 'admin', 'website_author')
    knitkit_application.add_capability('secure', 'Section', 'admin', 'website_author')
    knitkit_application.add_capability('unsecure', 'Section', 'admin', 'website_author')

    knitkit_application.add_capability('create', 'Layout', 'admin', 'layout_author')
    knitkit_application.add_capability('edit', 'Layout', 'admin', 'layout_author')

    knitkit_application.add_capability('create', 'Article', 'admin', 'content_author')
    knitkit_application.add_capability('delete', 'Article', 'admin', 'content_author')
    knitkit_application.add_capability('edit', 'Article', 'admin', 'content_author')
    knitkit_application.add_capability('publish', 'Article', 'admin', 'content_author')
    knitkit_application.add_capability('revert_version', 'Article', 'admin', 'content_author')
    knitkit_application.add_capability('add_existing', 'Article', 'admin', 'content_author')
    knitkit_application.add_capability('edit_html', 'Article', 'admin', 'content_author')
    knitkit_application.add_capability('edit_excerpt', 'Article', 'admin', 'content_author')

    knitkit_application.add_capability('create', 'MenuItem', 'admin', 'website_author')
    knitkit_application.add_capability('delete', 'MenuItem', 'admin', 'website_author')
    knitkit_application.add_capability('edit', 'MenuItem', 'admin', 'website_author')
    knitkit_application.add_capability('secure', 'MenuItem', 'admin', 'website_author')
    knitkit_application.add_capability('unsecure', 'MenuItem', 'admin', 'website_author')

    knitkit_application.add_capability('view', 'Theme', 'admin', 'designer')

    knitkit_application.add_capability('view', 'SiteImageAsset', 'admin', 'website_author', 'content_author')

    knitkit_application.add_capability('view', 'GlobalImageAsset', 'admin', 'website_author', 'content_author')
    knitkit_application.add_capability('upload', 'GlobalImageAsset', 'admin', 'website_author')
    knitkit_application.add_capability('delete', 'GlobalImageAsset', 'admin', 'website_author')

    knitkit_application.add_capability('view', 'SiteFileAsset', 'admin', 'website_author', 'content_author')

    knitkit_application.add_capability('view', 'GlobalFileAsset', 'admin', 'website_author', 'content_author')
    knitkit_application.add_capability('upload', 'GlobalFileAsset', 'admin', 'website_author')
    knitkit_application.add_capability('delete', 'GlobalFileAsset', 'admin', 'website_author')

    knitkit_application.add_capability('drag_item', 'WebsiteTree', 'admin', 'website_author')
  end
  
  def self.down
    knitkit_application = DesktopApplication.find_by_internal_identifier('knitkit')
    knitkit_application.remove_all_capabilities
  end

end
