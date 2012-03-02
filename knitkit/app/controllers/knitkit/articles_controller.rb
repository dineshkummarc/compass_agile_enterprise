module Knitkit
  class ArticlesController < BaseController
    def index
      @contents = Article.find_by_section_id(@website_section.id)
    end
  end
end
