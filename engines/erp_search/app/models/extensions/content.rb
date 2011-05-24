Content.class_eval do

  if $USE_SOLR_FOR_CONTENT

    searchable do
      text :title
      text :excerpt_html    
      text :body_html
      string :website_section_id do
        website_sections.first.id # index website_section_id so solr does not need reindexed when section title/permalink changes        
      end
      string :type do
        website_sections.first.type        
      end
      string :website_id do
        website_sections.first.website_id
      end
    end

    # alias_method :search, :solr_search unless method_defined? :search
    # the above line in sunspot plugin doesn't all you overwrite the search method in content base model.
    # add this to force overwriting it.
    def self.search(options = {}, &block)
      self.solr_search(options = {}, &block)
    end

    # overwrite and add solr functionality.
    def self.do_search(options = {})

      if options[:section_permalink].nil?
        website_section_id = nil
      else
        website_section_id = WebsiteSection.find_by_permalink(options[:section_permalink]).id rescue nil
      end

      @results = Content.search do
        unless options[:query].empty?
          keywords options[:query]
        end

        unless options[:content_type].nil? or options[:content_type].empty?
          with(:type, options[:content_type])
        end

        unless website_section_id.nil?
          with(:website_section_id, website_section_id)
        end

        with(:website_id, options[:website_id])
        paginate :page => options[:page], :per_page => options[:per_page]
      end

      @search_results = build_search_results(@results.results) 

      @page_results = WillPaginate::Collection.create(options[:page], options[:per_page], @results.results.total_entries) do |pager|
         pager.replace(@search_results)
      end

      return @page_results
    end

    def total_pages
      page_count
    end
    
    def after_save
      Sunspot.commit
    end

    def after_destroy
      Sunspot.commit
    end
  end
    
end