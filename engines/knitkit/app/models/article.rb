class Article < Content
  acts_as_taggable
  
  default_scope :order => "#{self.table_name}.created_at DESC"

  has_permalink :title

  def to_param
    permalink
  end
end
