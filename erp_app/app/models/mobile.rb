class Mobile < AppContainer


  class << self
    def find_by_user(user)
      Mobile.where('user_id = ?', user.id).first
    end
  end
  
end
