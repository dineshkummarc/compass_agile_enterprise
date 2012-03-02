class UserAppContainerObserver < ActiveRecord::Observer
  observe :user

  def after_create(user)
    desktop = ::Desktop.create
    desktop.user = user
    #make sure to setup default preferences
    desktop.setup_default_preferences

    organizer = Organizer.create
    organizer.user = user
    #make sure to setup default preferences
    organizer.setup_default_preferences
  end
end