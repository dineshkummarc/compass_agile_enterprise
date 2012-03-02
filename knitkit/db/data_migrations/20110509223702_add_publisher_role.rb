class AddPublisherRole
  
  def self.up
    Role.create(:internal_identifier => 'publisher', :description => 'Publisher')
    Role.create(:internal_identifier => 'content_author', :description => 'Content Author')
    Role.create(:internal_identifier => 'layout_author', :description => 'Layout Author')
    Role.create(:internal_identifier => 'editor', :description => 'Editor')
    Role.create(:internal_identifier => 'designer', :description => 'Designer')
    Role.create(:internal_identifier => 'website_author', :description => 'Website Author')
  end
  
  def self.down
    Role.iid('publisher').destroy
    Role.iid('content_author').destroy
    Role.iid('layout_author').destroy
    Role.iid('editor').destroy
    Role.iid('designer').destroy
    Role.iid('website_author').destroy
  end

end
