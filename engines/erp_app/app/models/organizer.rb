class Organizer < ActiveRecord::Base
  acts_as_app_container

  def setup_default_preferences
    #setup theme
    theme_pt = PreferenceType.iid('extjs_theme')
    theme_pt.preferenced_records << self
    theme_pt.save

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

  class << self
    def find_by_user(user)
      find_by_user_and_klass(user, Organizer)
    end
  end
end
