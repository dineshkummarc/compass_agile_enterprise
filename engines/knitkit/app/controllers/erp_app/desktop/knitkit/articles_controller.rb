class ErpApp::Desktop::Knitkit::ArticlesController < ErpApp::Desktop::Knitkit::BaseController
  IGNORED_PARAMS = %w{action controller id position section_id content_area}

  def new
    result = {}
    website_section_id = params[:section_id]
    article = Article.new

    article = set_attributes(article)
    article.website_sections << WebsiteSection.find(website_section_id)
    
    if article.save
      update_position_and_content_area(website_section_id, article)
      
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
    
    article = set_attributes(article)

    if article.save
      update_position_and_content_area(website_section_id, article)

      result[:success] = true
    else
      result[:success] = false
    end

    render :inline => result.to_json
  end
 
  def set_attributes(article)
    params.each do |k,v|
      if k == 'tags'
        article.tag_list = params[:tags].split(',').collect{|t| t.strip() }
      else
        article.send(k + '=', v) unless IGNORED_PARAMS.include?(k.to_s)
      end
    end
    
    article    
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
    Article.include_root_in_json = false
    render :inline => Article.all.to_json(:only => [:title, :id])
  end

  def get
    Article.include_root_in_json = false

    sort  = params[:sort] || 'created_at'
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

    articles_array = []
    articles.each do |a|
      articles_hash = {}
      articles_hash[:content_area] = get_section_content(website_section_id, a).content_area
      articles_hash[:id] = a.id
      articles_hash[:title] = a.title
      articles_hash[:tag_list] = a.tag_list.join(', ')
      articles_hash[:body_html] = a.body_html
      articles_hash[:excerpt_html] = a.excerpt_html
      articles_hash[:position] = a.position(website_section_id)
      articles_array << articles_hash
    end

    render :inline => "{totalCount:#{total_count},data:#{articles_array.to_json(:only => [:content_area, :id, :title, :tag_list, :body_html, :excerpt_html, :position], :methods => [:website_section_position])}}"
  end

  private

  def get_section_content(website_section_id, article)
    WebsiteSectionContent.find(:first, :conditions => ['website_section_id = ? and content_id = ?', website_section_id, article.id])
  end

  def update_position_and_content_area(website_section_id, article)
    section_content = get_section_content(website_section_id, article)
    section_content.content_area = params['content_area']
    section_content.position = params['position']
    section_content.save
  end
end
