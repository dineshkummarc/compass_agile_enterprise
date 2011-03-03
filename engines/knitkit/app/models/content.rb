class Content < ActiveRecord::Base
  acts_as_versioned
  
  has_many :section_contents
  has_many :sections, :through => :section_contents
    
  validates_presence_of :type
    
  def self.find_by_section_id( section_id )
    Content.find(:all, 
      :joins => "INNER JOIN section_contents ON section_contents.content_id = contents.id",
      :conditions => "section_id = #{section_id} ")
  end

  def self.find_published_by_site_section(site, section)
    published_content = []
    contents = self.find_by_section_id( section.id )
    contents.each do |content|
      content = get_published_verison(site, content)
      published_content << content unless content.nil?
    end

    published_content
  end

  def publish(site, comment)
    site.publish(comment)
  end
  
  def find_sections_by_site_id( site_id )
    self.sections.find(:all, :conditions => "site_id = #{site_id}")
  end

  def position( section_id )
    position = self.section_contents.find_by_section_id(section_id).position
    position
  end

  private

  def self.get_published_verison(site, content)
    content_version = nil
    published_site_id = site.active_publication.id
    published_element = PublishedElement.find(:first,
      :include => [:published_site],
      :conditions => ['published_sites.id = ? and published_element_record_id = ? and published_element_record_type = ?', published_site_id, content.id, 'Content'])
    unless published_element.nil?
      content_version = Content::Version.find_by_version(published_element.version)
    end
    content_version
  end
end
