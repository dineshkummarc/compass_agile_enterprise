Content.class_eval do

  if $USE_SOLR_FOR_CONTENT

    searchable do
      text :title
      text :excerpt_html    
      text :body_html
    end

    # alias_method :search, :solr_search unless method_defined? :search
    # the above line in sunspot plugin doesn't all you overwrite the search method in content base model.
    # add this to force overwriting it.
    def self.search
      self.solr_search
    end

    # overwrite and add solr functionality.
    def self.do_search(query = '', page = 1, per_page = 20)

      if $USE_SOLR_FOR_CONTENT
        @results = Content.search do
          unless query.empty?
            keywords query
          end
          paginate :page => page, :per_page => per_page
        end

        results = @results.results
      else
        #implement your own search hook here...
      end

      build_search_results(results)
    end

    def after_save
      Sunspot.commit
    end

    def after_destroy
      Sunspot.commit
    end
  end
    
end