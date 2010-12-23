User.class_eval do
  has_many :app_containers

  def desktop
    app_containers.find(:first, :conditions => ['app_container_record_type = ?','Desktop'])
  end

  def organizer
    app_containers.find(:first, :conditions => ['app_container_record_type = ?','Organizer'])
  end
end
