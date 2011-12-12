class ErpApp::Desktop::Knitkit::VersionsController < ErpApp::Desktop::Knitkit::BaseController
  #content

  def content_versions
    content   = Content.find(params[:id])
    website   = Website.find(params[:site_id])
    sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
    sort      = sort_hash[:property] || 'version'
    dir       = sort_hash[:direction] || 'DESC'
    limit     = params[:limit] || 15
    start     = params[:start] || 0

    versions = content.versions.find(:all, :order => "#{sort} #{dir}", :offset => start, :limit => limit)

    Content::Version.class_exec(website) do
      cattr_accessor :website
      self.website = website
      
      def active
        published_site_id = @@website.active_publication.id
        !PublishedElement.find(:first,
          :include => [:published_website],
          :conditions => ['published_websites.id = ? and published_element_record_id = ? and published_element_record_type = ? and published_elements.version = ?', published_site_id, self.content_id, 'Content', self.version]).nil?
      end
      
      def published_element
        PublishedElement.find(:first,
          :conditions => ['published_element_record_id = ? and published_element_record_type = ? and published_elements.version = ?', self.content_id, 'Content', self.version])
        PublishedElement.where('published_element_record_id = ? and published_element_record_type = ? and published_elements.version = ?', self.content_id, 'Content', self.version).first
      end
      
      def published
        !published_element.nil?
      end

      def publisher
        published_element.published_by_username if published
      end
    end

    render :inline => "{\"totalCount\":#{content.versions.count},data:#{versions.to_json(
                        :only => [:id, :version, :title, :body_html, :excerpt_html, :created_at],
                        :methods => [:active, :published, :publisher])}}"
  end

  def non_published_content_versions
    Content::Version.include_root_in_json = false

    content = Content.find(params[:id])
    sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
    sort = sort_hash[:property] || 'version'
    dir  = sort_hash[:direction] || 'DESC'
    limit = params[:limit] || 15
    start = params[:start] || 0

    versions = content.versions.find(:all, :order => "#{sort} #{dir}", :offset => start, :limit => limit)

    render :inline => "{\"totalCount\":#{content.versions.count},data:#{versions.to_json(
                        :only => [:id, :version, :title, :body_html, :excerpt_html, :created_at])}}"
  end

  def publish_content
    content = Content.find(Content::Version.find(params[:id]).content_id)
    website = Website.find(params[:site_id])
    version = params[:version]
    comment = params[:comment]

    content.publish(website, comment, version, current_user)

    render :inline => {:success => true}.to_json
  end

  def revert_content
    content = Content.find(Content::Version.find(params[:id]).content_id)
    version = params[:version]
    content.revert_to(version)
    content.save!

    render :inline => {:success => true}.to_json
  end

  #website section layouts

  def website_section_layout_versions
    
    website_section = WebsiteSection.find(params[:id])
    website = Website.find(params[:site_id])
    sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
    sort = sort_hash[:property] || 'version'
    dir  = sort_hash[:direction] || 'DESC'
    limit = params[:limit] || 15
    start = params[:start] || 0

    versions = website_section.versions.find(:all, :order => "#{sort} #{dir}", :offset => start, :limit => limit)

    WebsiteSection::Version.class_exec(website) do
      cattr_accessor :website
      self.website = website
      
      def active
        published_site_id = @@website.active_publication.id
        !PublishedElement.find(:first,
          :include => [:published_website],
          :conditions => ['published_websites.id = ? and published_element_record_id = ? and published_element_record_type = ? and published_elements.version = ?', published_site_id, self.website_section_id, 'WebsiteSection', self.version]).nil?
      end
      
      def published_element
        PublishedElement.find(:first,
          :conditions => ['published_element_record_id = ? and published_element_record_type = ? and published_elements.version = ?', self.website_section_id, 'WebsiteSection', self.version])
      end
      
      def published
        !published_element.nil?
      end

      def publisher
        published_element.published_by_username if published
      end
    end

    render :inline => "{\"totalCount\":#{website_section.versions.count},data:#{versions.to_json(
                        :only => [:id, :version, :title, :created_at], 
                        :methods => [:active, :published, :publisher])}}"
  end

  def get_website_section_version
    render :text => WebsiteSection::Version.find(params[:id]).layout
  end

  def publish_website_section
    website_section = WebsiteSection.find(WebsiteSection::Version.find(params[:id]).website_section_id)
    website = Website.find(params[:site_id])
    version = params[:version]
    comment = params[:comment]

    website_section.publish(website, comment, version, current_user)

    render :inline => {:success => true}.to_json
  end

  def revert_website_section
    website_section = WebsiteSection.find(WebsiteSection::Version.find(params[:id]).website_section_id)
    version = params[:version]
    website_section.revert_to(version)
    website_section.save!

    render :text => {:success => true, :body_html => website_section.layout}.to_json
  end
end
