class DocumentedContent < Content
  has_permalink :title
  before_save :check_internal_indentifier

  def to_param
    permalink
  end

  def check_internal_indentifier
    self.internal_identifier = self.permalink if self.internal_identifier.blank?
  end
  
  def content_hash
    {:id => self.id, :title => self.title, :body_html => self.body_html}  
  end
  
  def self.find_published_by_section(active_publication, website_section)
    published_content = []
    documented_item = DocumentedItem.where(["online_document_section_id = ?", website_section.id]).first
    if documented_item
      documented_content = DocumentedContent.find(documented_item.documented_content_id)
      content = get_published_version(active_publication, documented_content)
      published_content << content unless content.nil?
    end

    published_content.first
  end
  
end