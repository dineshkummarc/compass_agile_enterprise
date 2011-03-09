User.class_eval do
  has_many :comments, :dependent => :nullify

  alias :approved_comments :comments
end
