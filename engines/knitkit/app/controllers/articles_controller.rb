class ArticlesController < BaseController
  def index
    @contents = Article.find_by_section_id(@section.id)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contents }
    end
  end
end
