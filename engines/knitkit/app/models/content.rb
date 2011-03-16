class Content < ActiveRecord::Base
  acts_as_commentable
  acts_as_versioned
  can_be_published

  has_many :website_section_contents, :dependent => :destroy
  has_many :sections, :through => :website_section_contents
    
  validates_presence_of :type
  validates_uniqueness_of :title
    
  def self.find_by_section_id( website_section_id )
    Content.find(:all, 
      :joins => "INNER JOIN website_section_contents ON website_section_contents.content_id = contents.id",
      :conditions => "website_section_id = #{website_section_id} ")
  end

  def self.find_published_by_section(active_publication, website_section)
    published_content = []
    contents = self.find_by_section_id( website_section.id )
    contents.each do |content|
      content = get_published_verison(active_publication, content)
      published_content << content unless content.nil?
    end

    published_content
  end

  def find_website_sections_by_site_id( website_id )
    self.website_sections.find(:all, :conditions => "website_id = #{website_id}")
  end

  def position( website_section_id )
    position = self.website_section_contents.find_by_website_section_id(website_section_id).position
    position
  end

  def add_comment(options={})
    self.comments.create(options)
  end

  def get_comments(limit)
     self.commentable.comments.recent.limit(limit).all
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
