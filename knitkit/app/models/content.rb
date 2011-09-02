require 'will_paginate/array'

class Content < ActiveRecord::Base
  acts_as_taggable
  acts_as_commentable
  acts_as_versioned  :table_name => :content_versions
  can_be_published

  has_many :website_section_contents, :dependent => :destroy
  has_many :website_sections, :through => :website_section_contents
  belongs_to :created_by, :class_name => "User"
  belongs_to :updated_by, :class_name => "User"
    
  validates_presence_of :type
  validates_uniqueness_of :title

  def self.search(options = {})
    if options[:section_permalink].nil? or options[:section_permalink].empty?
      section_scope = ''
    else
      section_scope = "website_sections.permalink = '#{options[:section_permalink]}' AND"
    end

    if options[:content_type].nil? or options[:content_type].empty?
      content_type_scope = ''
    else
      content_type_scope = "website_sections.type = '#{options[:content_type]}' AND"
    end
 
    Content.includes([:website_sections]).where("#{content_type_scope} #{section_scope} 
                    website_sections.website_id = #{options[:website_id]} AND
                    (UPPER(contents.title) LIKE UPPER('%#{options[:query]}%') 
                      OR UPPER(contents.excerpt_html) LIKE UPPER('%#{options[:query]}%') 
                      OR UPPER(contents.body_html) LIKE UPPER('%#{options[:query]}%') )").order("contents.created_at DESC").all.paginate(:page => options[:page], :per_page => options[:per_page])
  end

  def self.do_search(options = {})    
    @results = Content.search(options)

    @search_results = build_search_results(@results) 
    
    @page_results = WillPaginate::Collection.create(options[:page], options[:per_page], @results.total_entries) do |pager|
      pager.replace(@search_results)
    end
    
    return @page_results
  end
      
  def self.find_by_section_id( website_section_id )
    Content.joins(:website_section_contents).where('website_section_id = ?', website_section_id).order("website_section_contents.position ASC, website_section_contents.created_at DESC").all
  end

  def self.find_by_section_id_filtered_by_id( website_section_id, id_filter_list )
    Content.joins(:website_section_contents).where("website_section_id = ? AND contents.id IN (#{id_filter_list.join(',')})", website_section_id).all
  end

  def self.find_published_by_section(active_publication, website_section)
    published_content = []
    contents = self.find_by_section_id( website_section.id )
    contents.each do |content|
      content = get_published_version(active_publication, content)
      published_content << content unless content.nil?
    end

    published_content
  end

  def self.find_published_by_section_with_tag(active_publication, website_section, tag)
    published_content = []    
    id_filter_list = self.tagged_with(tag.name).collect{|t| t.id }    
    contents = self.find_by_section_id_filtered_by_id( website_section.id, id_filter_list )
    contents.each do |content|
      content = get_published_version(active_publication, content)
      published_content << content unless content.nil?
    end

    published_content
  end

  def find_website_sections_by_site_id( website_id )
    self.website_sections.where('website_id = ?',website_id).all
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

  def update_content_area_and_position_by_section(section, content_area, position)
    website_section_content = WebsiteSectionContent.where('content_id = ? and website_section_id = ?',self.id, section.id).first
    unless website_section_content.nil?
      website_section_content.content_area = content_area
      website_section_content.position = position
      website_section_content.save
    end
  end

  def content_area_by_website_section(section)
    content_area = nil
    unless WebsiteSectionContent.where('content_id = ? and website_section_id = ?',self.id, section.id).first.nil?
      content_area = WebsiteSectionContent.where('content_id = ? and website_section_id = ?',self.id, section.id).first.content_area
    end
    content_area
  end

  def position_by_website_section(section)
    position = nil
    unless WebsiteSectionContent.where('content_id = ? and website_section_id = ?',self.id, section.id).first.nil?
      position = WebsiteSectionContent.where('content_id = ? and website_section_id = ?',self.id, section.id).first.position
    end
    position
  end

  protected
  
  def self.build_search_results(results)
    # and if it is a blog get the article link and title
    results_array = []
    results.each do |content|
      section = content.website_sections.first

      results_hash = {}
      if section.attributes['type'] == 'Blog'
        results_hash[:link] = section.permalink + '/' + content.permalink
        results_hash[:title] = content.title
      else
        results_hash[:link] = section.permalink
        results_hash[:title] = section.title
      end
      results_hash[:section] = section
      results_hash[:content] = content

      results_array << results_hash
    end
    
    results_array
  end

  private

  def self.get_published_version(active_publication, content)
    content_version = nil
    published_website_id = active_publication.id
    published_element = PublishedElement.includes([:published_website]).where('published_websites.id = ? and published_element_record_id = ? and published_element_record_type = ?', published_website_id, content.id, 'Content').first
    unless published_element.nil?
      content_version = Content::Version.where('version = ? and content_id = ?', published_element.version, published_element.published_element_record_id).first
    end
    content_version
  end
end
