class Note < ActiveRecord::Base
  def created_by_username
    created_by.user.username
  end
end
