class Organizer < ActiveRecord::Base
  acts_as_app_container

  def self.find_by_user(user)
    find_by_user_and_klass(user, Organizer)
  end

  def setup_default_preferences
    #setup desktop background
    desktop_backgroud_pt = PreferenceType.iid('desktop_background')
    desktop_backgroud_pt.preferenced_records << self

    pref = Preference.create(
      :preference_type => desktop_backgroud_pt,
      :preference_option => PreferenceOption.iid('portablemind_desktop_background')
    )

    self.user_preferences << UserPreference.create(
      :user => self.user,
      :preference => pref
    )

    #setup theme
    theme_pt = PreferenceType.iid('extjs_theme')
    theme_pt.preferenced_records << self

    pref = Preference.create(
      :preference_type => theme_pt,
      :preference_option => PreferenceOption.iid('blue_extjs_theme')
    )

    self.user_preferences << UserPreference.create(
      :user => self.user,
      :preference => pref
    )

    self.save
  end
end
