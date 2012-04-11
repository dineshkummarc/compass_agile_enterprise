class UserAppContainerObserver < ActiveRecord::Observer
  observe :user

  def after_create(user)
    desktop = ::Desktop.create
    desktop.user = user
    desktop.setup_default_preferences
    desktop.save

    organizer = Organizer.create
    organizer.user = user
    organizer.setup_default_preferences
    organizer.save

    mobile = Mobile.create
    mobile.user = user
    mobile.setup_default_preferences
    mobile.save
  end
end