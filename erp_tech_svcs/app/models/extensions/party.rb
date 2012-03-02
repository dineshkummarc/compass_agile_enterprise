Party.class_eval do
  has_one :user, :dependent => :destroy
end
