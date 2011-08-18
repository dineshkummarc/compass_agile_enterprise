Party.class_eval do
   #for authentication credentials
  has_one :user, :dependent => :destroy
end
