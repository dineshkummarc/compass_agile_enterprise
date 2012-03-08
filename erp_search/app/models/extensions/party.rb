Party.class_eval do
  has_one :party_search_fact, :dependent => :destroy

  # alias_method :search, :solr_search unless method_defined? :search
  # the above line in sunspot plugin doesn't allow you to overwrite the search method in base model.
  # add this to force overwriting it.
  def self.search(options = {}, &block)
    self.solr_search(options = {}, &block)
  end

  def self.do_search(options = {})   
    options[:sort] = 'individual_current_last_name' if options[:sort].blank?
    
    search_results = PartySearchFact.search do
            keywords options[:query]
            paginate :page => options[:page], :per_page => options[:per_page]
            order_by options[:sort].to_sym, options[:dir].to_sym
          end

    search_results.results
  end

end
