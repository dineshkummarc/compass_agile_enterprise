Content.class_eval do

  if $USE_SOLR_FOR_CONTENT

    searchable do
      text :title
      text :excerpt_html    
      text :body_html
      string :website_id do
        website_sections.first.website_id
      end
    end

    # alias_method :search, :solr_search unless method_defined? :search
    # the above line in sunspot plugin doesn't all you overwrite the search method in content base model.
    # add this to force overwriting it.
    # THIS IS NOT WORKING CORRECTLY! You must still call solr_search directly!
    def self.search
      self.solr_search
    end

    # overwrite and add solr functionality.
    def self.do_search(website_id, query = '', page = 1, per_page = 20)

      @results = Content.solr_search do
        unless query.empty?
          keywords query
        end

        with(:website_id, website_id)
        paginate :page => page, :per_page => per_page
      end

      build_search_results(@results.results)
    end

    def after_save
      Sunspot.commit
    end

    def after_destroy
      Sunspot.commit
    end
  end
    
end