class UserAppContainerObserver < ActiveRecord::Observer
  observe :user

  def after_create(user)
    desktop = ::Desktop.create
    desktop.user = user
    desktop.setup_default_preferences

    organizer = Organizer.create
    organizer.user = user
    organizer.setup_default_preferences

    mobile = Mobile.create
    mobile.user = user
    mobile.setup_default_preferences
  end
end