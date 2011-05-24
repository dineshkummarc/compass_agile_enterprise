class Content < ActiveRecord::Base
  acts_as_taggable
  acts_as_commentable
  acts_as_versioned
  can_be_published

  has_many :website_section_contents, :dependent => :destroy
  has_many :website_sections, :through => :website_section_contents
    
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
    
    Content.find(:all,
      :joins => :website_sections,
      :conditions => "#{content_type_scope} #{section_scope} 
                      website_sections.website_id = #{options[:website_id]} AND
                      (contents.title LIKE '%#{options[:query]}%' 
                      OR contents.excerpt_html LIKE '%#{options[:query]}%' 
                      OR contents.body_html LIKE '%#{options[:query]}%')",
      :order => "contents.created_at DESC").paginate(:page => options[:page], :per_page => options[:per_page])
  end

  def self.do_search(options = {})    
    @results = Content.search(options)

    build_search_results(@results)    
  end
      
  def self.find_by_section_id( website_section_id )
    Content.find(:all, 
      :joins => "INNER JOIN website_section_contents ON website_section_contents.content_id = contents.id",
      :conditions => "website_section_id = #{website_section_id} ",
      :order => "website_section_contents.position ASC, website_section_contents.created_at DESC")
  end

  def self.find_by_section_id_filtered_by_id( website_section_id, id_filter_list )
    Content.find(:all, 
      :joins => "INNER JOIN website_section_contents ON website_section_contents.content_id = contents.id",
      :conditions => "website_section_id = #{website_section_id} AND contents.id IN (#{id_filter_list.join(',')})")
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

  def self.find_published_by_section_with_tag(active_publication, website_section, tag)
    published_content = []    
    id_filter_list = self.tagged_with(tag.name).collect{|t| t.id }    
    contents = self.find_by_section_id_filtered_by_id( website_section.id, id_filter_list )
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
