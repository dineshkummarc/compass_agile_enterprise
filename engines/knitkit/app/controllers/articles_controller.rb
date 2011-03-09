class ArticlesController < BaseController
  def index
    @contents = Article.find_by_section_id(@section.id)
  end
end
