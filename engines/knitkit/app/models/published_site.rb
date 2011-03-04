class PublishedSite < ActiveRecord::Base
  belongs_to :site
  has_many   :published_elements, :dependent => :destroy

  def self.activate(site, version)
    published_sites = self.find(:all, :conditions => ['site_id = ?', site.id])
    published_sites.each do |published_site|
      if published_site.version == version
        published_site.active = true
      else
        published_site.active = false
      end
      published_site.save
    end
  end

  def publish(comment)
    new_publication = clone_publication(1, comment)
    elements = []

    sections = new_publication.site.sections
    sections.each do |section|
      elements = elements | section.contents
    end
    elements = elements | sections

    #make sure all elements have published_element objects
    elements.each do |element|
      if new_publication.published_elements.find(:first,
          :conditions => ['published_element_record_id = ? and (published_element_record_type = ? or published_element_record_type = ?)', element.id, element.class.to_s, element.class.superclass.to_s]).nil?
        published_element = PublishedElement.new
        published_element.published_site = new_publication
        published_element.published_element_record = element
        published_element.version = element.version
        published_element.save
      end
    end

    #get latest version for all elements
    new_publication.published_elements.each do |published_element|
      published_element.version = published_element.published_element_record.version
      published_element.save
    end

    PublishedSite.activate(new_publication.site, new_publication.version)
  end

  def publish_element(comment, element, version)
    new_publication = clone_publication(0.1, comment)

    published_element = new_publication.published_elements.find(:first,
      :conditions => ['published_element_record_id = ? and (published_element_record_type = ? or published_element_record_type = ?)', element.id, element.class.to_s, element.class.superclass.to_s])

    unless published_element.nil?
      published_element.version = version
      published_element.save
    else
      new_published_element = PublishedElement.new
      new_published_element.published_site = new_publication
      new_published_element.published_element_record = element
      new_published_element.version = version
      new_published_element.save
    end

    PublishedSite.activate(new_publication.site, new_publication.version)
  end

  private
  
  def clone_publication(version_increment, comment)
    #create new PublishedSite with comment
    published_site = PublishedSite.new
    published_site.site = self.site
    if version_increment == 1
      published_site.version = (self.version = self.version.to_i + version_increment)
    else
      published_site.version = (self.version += version_increment)
    end

    published_site.comment = comment
    published_site.save
    
    #create new PublishedSiteElements
    published_elements.each do |published_element|
      new_published_element = PublishedElement.new
      new_published_element.published_site = published_site
      new_published_element.published_element_record = published_element.published_element_record
      new_published_element.version = published_element.version
      new_published_element.save
    end

    published_site
  end
end