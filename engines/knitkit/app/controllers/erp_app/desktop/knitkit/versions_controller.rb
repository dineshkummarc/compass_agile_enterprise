class ErpApp::Desktop::Knitkit::VersionsController < ErpApp::Desktop::Knitkit::BaseController
  def content_versions
    content = Content.find(params[:content_id])
    site = Site.find(params[:site_id])
    sort  = params[:sort] || 'version'
    dir   = params[:dir] || 'DESC'
    limit = params[:limit] || 15
    start = params[:start] || 0

    versions = content.versions.find(:all, :order => "#{sort} #{dir}", :offset => start, :limit => limit)

    Content::Version.class_exec(site) do
      @@site = site
      def published
        published_site_id = @@site.active_publication.id
        !PublishedElement.find(:first,
          :include => [:published_site],
          :conditions => ['published_sites.id = ? and published_element_record_id = ? and published_element_record_type = ? and published_elements.version = ?', published_site_id, self.content_id, 'Content', self.version]).nil?
      end
    end

    render :inline => "{\"totalCount\":#{content.versions.count},data:#{versions.to_json(:only => [:id, :version, :title, :body_html, :excerpt_html, :created_at], :methods => [:published])}}"
  end

  def publish_content
    content = Content.find(Content::Version.find(params[:id]).content_id)
    site    = Site.find(params[:site_id])
    version = params[:version]
    comment = params[:comment]

    content.publish(site, comment, version)

    render :inline => {:success => true}.to_json
  end

  def revert_content
    content = Content.find(Content::Version.find(params[:id]).content_id)
    version = params[:version]
    content.revert_to(version)
    content.save!

    render :inline => {:success => true}.to_json
  end

  def layout_versions

  end
end
