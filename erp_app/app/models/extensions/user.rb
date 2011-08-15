User.class_eval do
  has_many :app_containers, :dependent => :destroy

  def desktop
    Desktop.find(:first, :include => :app_container, :conditions => ['app_containers.user_id = ?', self.id])
  end

  def organizer
    Organizer.find(:first, :include => :app_container, :conditions => ['app_containers.user_id = ?', self.id])
  end
end
