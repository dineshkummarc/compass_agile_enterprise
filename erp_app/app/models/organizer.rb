class Organizer < AppContainer
  def setup_default_preferences
    #setup theme
    theme_pt = PreferenceType.iid('extjs_theme')
    self.preference_types << theme_pt

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
      Organizer.where('user_id = ?', user.id).first
    end
  end
end
