class WebsiteSection < ActiveRecord::Base
  acts_as_versioned
  self.non_versioned_columns =  self.non_versioned_columns | %w{parent_id lft rgt}

  can_be_published
  has_security
  
  KNIT_KIT_ROOT = "#{RAILS_ROOT}/vendor/plugins/knitkit/"
  WEBSITE_SECTIONS_TEMP_LAYOUT_PATH = "#{RAILS_ROOT}/vendor/plugins/knitkit/app/views/website_sections/"
  
  @@types = ['Page']
  cattr_reader :types

  #was deleting all records. Explore this..
  #acts_as_nested_set :scope => :website_id if ActiveRecord::Base.connection.tables.include?('website_sections') #better nested set tries to use this before the table is there...

  acts_as_nested_set if ActiveRecord::Base.connection.tables.include?('website_sections') #better nested set tries to use this before the table is there...
  

  belongs_to :website
  has_many :website_section_contents, :dependent => :destroy
  has_many :contents, :through => :website_section_contents

  validates_uniqueness_of :title
  has_permalink :title, :update => true
  
  def articles 
    articles = Article.find_by_section_id(self.id)
    articles
  end
  
  class << self
    def register_type(type)
      @@types << type
      @@types.uniq!
    end
  end
  
  def positioned_children
    children.sort_by{|child| [child.position]}
  end

  def permalinks
    links = [self.permalink]
    links | self.all_children.collect(&:permalink)
  end

  def child_by_permalink(path)
    self.all_children.detect{|child| child.permalink == path}
  end
  
  def type
    read_attribute(:type) || 'Page'
  end

  def create_layout
    self.layout = IO.read(File.join(KNIT_KIT_ROOT,"app/views/website_sections/index.html.erb"))
    self.save
  end

  def get_published_layout(active_publication)
    layout_content = nil
    published_website_id = active_publication.id
    published_element = PublishedElement.find(:first,
      :include => [:published_website],
      :conditions => ['published_websites.id = ? and published_element_record_id = ? and published_element_record_type = ?', published_website_id, self.id, 'WebsiteSection'])
    unless published_element.nil?
      layout_content = WebsiteSection::Version.find(:first, :conditions => ['version = ? and website_section_id = ?', published_element.version, published_element.published_element_record_id]).layout
    else
      layout_content = IO.read(File.join(KNIT_KIT_ROOT,"app/views/website_sections/index.html.erb"))
    end
    layout_content
  end

  private

  def self.get_published_verison(active_publication, content)
    content_version = nil
    published_website_id = active_publication.id
    published_element = PublishedElement.find(:first,
      :include => [:published_website],
      :conditions => ['published_websites.id = ? and published_element_record_id = ? and published_element_record_type = ?', published_website_id, content.id, 'Content'])
    unless published_element.nil?
      content_version = Content::Version.find(:first, :conditions => ['version = ? and content_id = ?', published_element.version, published_element.published_element_record_id])
    end
    content_version
  end
end


