class PublishedWebsite < ActiveRecord::Base
  belongs_to :website
  has_many   :published_elements, :dependent => :destroy

  def self.activate(website, version)
    published_websites = where('website_id = ?',website.id).all
    published_websites.each do |published_website|
      published_website.active = (published_website.version == version) ? true : false
      published_website.save
    end
  end

  def publish(comment)
    new_publication = clone_publication(1, comment)
    elements = []

    #get a publish sections
    website_sections = new_publication.website.website_sections
    website_sections = website_sections | website_sections.collect{|section| section.descendants}.flatten
    website_sections.each do |website_section|
      if new_publication.published_elements.where('published_element_record_id = ? and (published_element_record_type = ? or published_element_record_type = ?)', website_section.id, website_section.class.to_s, website_section.class.superclass.to_s).first.nil?
        published_element = PublishedElement.new
        published_element.published_website = new_publication
        published_element.published_element_record = website_section
        published_element.version = website_section.version
        published_element.save
      end

      elements = elements | website_section.contents
    end

    #make sure all elements have published_element objects
    elements.each do |element|
      if new_publication.published_elements.where('published_element_record_id = ? and (published_element_record_type = ? or published_element_record_type = ?)', element.id, element.class.to_s, element.class.superclass.to_s).first.nil?
        published_element = PublishedElement.new
        published_element.published_website = new_publication
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

    #check if we want to auto active this publication
    PublishedWebsite.activate(new_publication.website, new_publication.version) if new_publication.website.auto_activate_publication?
  end

  def publish_element(comment, element, version)
    new_publication = clone_publication(0.1, comment)

    published_element = new_publication.published_elements.where('published_element_record_id = ? and (published_element_record_type = ? or published_element_record_type = ?)', element.id, element.class.to_s, element.class.superclass.to_s).first

    unless published_element.nil?
      published_element.version = version
      published_element.save
    else
      new_published_element = PublishedElement.new
      new_published_element.published_website = new_publication
      new_published_element.published_element_record = element
      new_published_element.version = version
      new_published_element.save
    end

    #check if we want to auto active this publication
    PublishedWebsite.activate(new_publication.website, new_publication.version) if new_publication.website.auto_activate_publication?
  end

  private
  
  def clone_publication(version_increment, comment)
    #create new PublishedWebsite with comment
    published_website = PublishedWebsite.new
    published_website.website = self.website
    published_website.version == (version_increment == 1) ? (self.version = self.version.to_i + version_increment) : (self.version += version_increment)
    published_website.comment = comment
    published_website.save
    
    #create new PublishedWebsiteElements
    published_elements.each do |published_element|
      new_published_element = PublishedElement.new
      new_published_element.published_website = published_website
      new_published_element.published_element_record = published_element.published_element_record
      new_published_element.version = published_element.version
      new_published_element.save
    end

    published_website
  end
end