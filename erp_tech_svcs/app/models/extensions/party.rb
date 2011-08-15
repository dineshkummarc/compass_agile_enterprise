Party.class_eval do
   #for authentication credentials
  has_one :user, :dependent => :destroy

  #Return username
  def username
    user.nil? ? nil : user.login
  end

end
