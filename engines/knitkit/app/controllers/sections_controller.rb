 class SectionsController < BaseController
  def index
    @contents = Article.find_by_section_id(@section.id)
    render @section.template unless @section.template.nil?
  end
end
