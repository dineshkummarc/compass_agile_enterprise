Content.class_eval do

  if $USE_SOLR_FOR_CONTENT
    searchable do
      text :title
      text :excerpt_html    
      text :body_html
    end

    def after_save
      Sunspot.commit
    end

    def after_destroy
      Sunspot.commit
    end
  end
    
  
end