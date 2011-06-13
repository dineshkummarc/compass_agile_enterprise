Party.class_eval do
  has_one :party_search_fact, :dependent => :destroy
end
