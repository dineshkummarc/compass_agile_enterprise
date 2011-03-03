class ErpApp::Desktop::Knitkit::ArticlesController < ErpApp::Desktop::Knitkit::BaseController
  IGNORED_PARAMS = %w{action controller position section_id}

  def new
    result = {}
    section_id = params[:section_id]
    article = Article.new

    params.each do |k,v|
      article.send(k + '=', v) unless IGNORED_PARAMS.include?(k.to_s)
    end

    section = Section.find(section_id)
    section.contents << article

    if article.save
      result[:success] = true
    else
      result[:success] = false
    end

    render :inline => result.to_json
  end

  def update
    result = {}
    section_id = params[:section_id]
    article = Article.find(params[:id])
    
    params.each do |k,v|
      article.send(k + '=', v) unless IGNORED_PARAMS.include?(k.to_s)
    end

    #handle position
    section_content = SectionContent.find(:first, :conditions => ['section_id = ? and content_id = ?',section_id,article.id])
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

    if Article.delete(params[:id])
      result[:success] = true
    else
      result[:success] = false
    end

    render :inline => result.to_json
  end

  def get
    Article.include_root_in_json = false

    sort  = params[:sort] || 'title'
    dir   = params[:dir] || 'DESC'
    limit = params[:limit] || 10
    start = params[:start] || 0

    section_id = params[:section_id]
    articles = Article.find(:all,
      :joins => "INNER JOIN section_contents ON section_contents.content_id = contents.id",
      :conditions => "section_id = #{section_id} ",
      :order => "#{sort} #{dir}",
      :limit => limit,
      :offset => start)

    total_count = Article.find(:all,
      :joins => "INNER JOIN section_contents ON section_contents.content_id = contents.id",
      :conditions => "section_id = #{section_id} ").count

    Article.class_exec(section_id) do
      @@section_id = section_id
      def section_position
        self.section_contents.find_by_section_id(@@section_id).position
      end
    end

    render :inline => "{totalCount:#{total_count},data:#{articles.to_json(:only => [:content_area, :id, :title, :body_html, :excerpt_html], :methods => [:section_position])}}"
  end
end
