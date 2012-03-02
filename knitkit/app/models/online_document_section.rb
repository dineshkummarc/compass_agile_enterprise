class OnlineDocumentSection < WebsiteSection
  has_one :documented_item, :dependent => :destroy
  delegate :content, :to => :documented_item, :prefix => true
  delegate :published_content, :to => :documented_item, :prefix => true
  has_permalink :title, :url_attribute => :permalink, :sync_url => true, :only_when_blank => true, :scope => [:website_id, :parent_id]
  
  def documented_item_content_html
    documented_item_content.body_html
  rescue
    nil
  end
  
  def documented_item_published_content_html(active_publication)
    documented_item_published_content(active_publication).body_html
  rescue
    nil
  end
  
  def build_section_hash
    section_hash = {
      :name => self.title,
      :has_layout => false,
      :type => self.class.to_s,
      :in_menu => self.in_menu,
      :roles => self.roles.collect{|role| role.internal_identifier},
      :path => self.path,
      :permalink => self.permalink,
      :internal_identifier => self.internal_identifier,
      :position => self.position,
      :online_document_sections => self.children.each.map{|child| child.build_section_hash},
      :articles => [],
      :documented_item => {
        :name => documented_item_content.title,
        :display_title => documented_item_content.display_title,
        :internal_identifier => documented_item_content.internal_identifier
      }
    }
    section_hash
  end
end