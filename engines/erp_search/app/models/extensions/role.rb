Role.class_eval do
  searchable do
    text :internal_identifier
    text :description    
    string :internal_identifier
    string :description
  end

  def after_save
    Sunspot.commit
  end

  def after_destroy
    Sunspot.commit
  end
  
end