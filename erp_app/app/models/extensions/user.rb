User.class_eval do
  has_many :app_containers, :dependent => :destroy

  def desktop
    Desktop.includes([:app_container]).where('app_containers.user_id = ?', self.id).first
  end

  def organizer
    Organizer.includes([:app_container]).where('app_containers.user_id = ?', self.id).first
  end
end
