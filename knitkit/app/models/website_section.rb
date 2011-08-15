class WebsiteSection < ActiveRecord::Base
  acts_as_versioned :table_name => :website_section_versions, :non_versioned_columns => %w{parent_id lft rgt}
  can_be_published
  has_security
  
  KNIT_KIT_ROOT = Knitkit::Engine.root.to_s
  WEBSITE_SECTIONS_TEMP_LAYOUT_PATH = "#{Knitkit::Engine.root.to_s}/app/views/knitkit/website_sections"
  
  @@types = ['Page']
  cattr_reader :types

  #was deleting all records. Explore this..
  #acts_as_nested_set :scope => :website_id if ActiveRecord::Base.connection.tables.include?('website_sections') #better nested set tries to use this before the table is there...

  acts_as_nested_set if ActiveRecord::Base.connection.tables.include?('website_sections') #better nested set tries to use this before the table is there...
  
  belongs_to :website
  has_many :website_section_contents, :dependent => :destroy
  has_many :contents, :through => :website_section_contents

  validates_uniqueness_of :title, :scope => :website_id
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
    links | self.descendants.collect(&:permalink)
  end

  def child_by_permalink(path)
    self.descendants.detect{|child| child.permalink == path}
  end
  
  def type
    read_attribute(:type) || 'Page'
  end

  def create_layout
    self.layout = IO.read(File.join(WEBSITE_SECTIONS_TEMP_LAYOUT_PATH,"index.html.erb"))
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
      layout_content = IO.read(File.join(WEBSITE_SECTIONS_TEMP_LAYOUT_PATH,"index.html.erb"))
    end
    layout_content
  end

  def get_tags
    get_topics
  end
  
  def get_topics
    sql = "SELECT tags.*, taggings.tags_count AS count FROM \"tags\" 
                  JOIN (SELECT taggings.tag_id, COUNT(taggings.tag_id) AS tags_count FROM \"taggings\" 
                        INNER JOIN contents ON contents.id = taggings.taggable_id AND contents.type = 'Article' 
                        INNER JOIN website_section_contents ON contents.id=website_section_contents.content_id 
                        WHERE (taggings.taggable_type = 'Content' AND taggings.context = 'tags') 
                        AND website_section_contents.website_section_id=#{self.id}
                        GROUP BY taggings.tag_id HAVING COUNT(*) > 0 AND COUNT(taggings.tag_id) > 0) 
                        AS taggings ON taggings.tag_id = tags.id
                  ORDER BY tags.name ASC"

    ActsAsTaggableOn::Tag.find_by_sql(sql)
  end

  private

  def self.get_published_version(active_publication, content)
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


