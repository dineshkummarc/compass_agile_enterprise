class Article < Content
  has_permalink :title

  before_save :check_internal_indentifier

  def to_param
    permalink
  end

  def check_internal_indentifier
    if self.internal_identifier.blank?
      self.internal_identifier = self.permalink
    end
  end
end
