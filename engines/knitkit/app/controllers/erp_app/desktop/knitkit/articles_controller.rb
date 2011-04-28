class ErpApp::Desktop::Knitkit::ArticlesController < ErpApp::Desktop::Knitkit::BaseController
  IGNORED_PARAMS = %w{action controller position section_id}

  def new
    result = {}
    website_section_id = params[:section_id]
    article = Article.new

    params.each do |k,v|
      article.send(k + '=', v) unless IGNORED_PARAMS.include?(k.to_s)
    end

    if article.save
      section = WebsiteSection.find(website_section_id)
      section.contents << article
      result[:success] = true
    else
      result[:success] = false
    end

    render :inline => result.to_json
  end

  def update
    result = {}
    website_section_id = params[:section_id]
    article = Article.find(params[:id])
    
    params.each do |k,v|
      article.send(k + '=', v) unless IGNORED_PARAMS.include?(k.to_s)
    end

    #handle position
    section_content = WebsiteSectionContent.find(:first, :conditions => ['website_section_id = ? and content_id = ?',website_section_id,article.id])
    section_content.position = params['position']
    section_content.save
    
    if article.save
      result[:success] = true
    else
      result[:success] = false
    end

    render :inline => result.to_json
  end
 
  def delete
    result = {}

    if Article.destroy(params[:id])
      result[:success] = true
    else
      result[:success] = false
    end

    render :inline => result.to_json
  end

  def add_existing
    website_section = WebsiteSection.find(params[:section_id])
    website_section.contents << Article.find(params[:article_id])

    render :inline => {:success => true}.to_json
  end

  def existing_articles
    current_articles = Article.find(:all,
        :joins => "INNER JOIN website_section_contents ON website_section_contents.content_id = contents.id",
      :conditions => "website_section_id = #{params[:section_id]}")

    available_articles = Article.all - current_articles

    render :inline => available_articles.to_json(:only => [:title, :id])
  end

  def get
    Article.include_root_in_json = false

    sort  = params[:sort] || 'title'
    dir   = params[:dir] || 'DESC'
    limit = params[:limit] || 10
    start = params[:start] || 0

    website_section_id = params[:section_id]
    articles = Article.find(:all,
      :joins => "INNER JOIN website_section_contents ON website_section_contents.content_id = contents.id",
      :conditions => "website_section_id = #{website_section_id}",
      :order => "#{sort} #{dir}",
      :limit => limit,
      :offset => start)

    total_count = Article.find(:all,
      :joins => "INNER JOIN website_section_contents ON website_section_contents.content_id = contents.id",
      :conditions => "website_section_id = #{website_section_id}").count

    Article.class_exec(website_section_id) do
      @@website_section_id = website_section_id
      def website_section_position
        self.website_section_contents.find_by_website_section_id(@@website_section_id).position
      end
    end

    render :inline => "{totalCount:#{total_count},data:#{articles.to_json(:only => [:content_area, :id, :title, :body_html, :excerpt_html], :methods => [:website_section_position])}}"
  end
end
