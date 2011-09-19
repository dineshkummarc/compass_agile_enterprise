Role.class_eval do
  after_save :sunspot_commit
  after_destroy :sunspot_commit
  
  searchable do
    text :internal_identifier
    text :description    
    string :internal_identifier
    string :description
  end
  
  def sunspot_commit
    Sunspot.commit    
  end
  
end