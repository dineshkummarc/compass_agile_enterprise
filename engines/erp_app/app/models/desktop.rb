class Desktop < ActiveRecord::Base
  acts_as_app_container

  def self.find_by_user(user)
    find_by_user_and_klass(user, Desktop)
  end

  def setup_default_preferences
    desktop_backgroud_pt = PreferenceType.iid('desktop_background')
    desktop_backgroud_pt.preferenced_records << self

    pref = Preference.create(
      :preference_type => desktop_backgroud_pt,
      :preference_option => PreferenceOption.iid('default_desktop_background')
    )

    self.user_preferences << UserPreference.create(
      :user => self.user,
      :preference => pref
    )

    self.save
  end
end
