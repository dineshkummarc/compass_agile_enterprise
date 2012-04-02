User.class_eval do
  has_many :app_containers, :dependent => :destroy
  has_many :user_preferences, :dependent => :destroy

  def desktop
    Desktop.where('user_id = ?', self.id).first
  end

  def organizer
    Organizer.where('user_id = ?', self.id).first
  end

  def mobile
    Mobile.where('user_id = ?', self.id).first
  end

  def get_preference(preference_type)
    preference_type = PreferenceType.iid(preference_type) if preference_type.is_a? String
    raise 'Preference type does not exist' if preference_type.nil?
    user_preference = self.user_preferences.joins('join preferences on preferences.id = user_preferences.preference_id')
                                           .where('preference_type_id = ?', preference_type.id).first
    unless user_preference.nil?
      user_preference.preference.preference_option.value
    else
      raise 'User does not have preference'
    end
  end

  #preference_option can be internal_identifier or value
  def set_preference(preference_type, preference_option)
    preference_type = PreferenceType.iid(preference_type) if preference_type.is_a? String
    raise 'Preference type does not exist' if preference_type.nil?

    preference_option = PreferenceOption.iid(preference_option) if preference_option.is_a? String
    preference_option = PreferenceOption.find_by_value(preference_option) if (preference_option.is_a? String and preference_option.nil?)
    raise 'Preference option does not exist' if preference_option.nil?

    user_preference = user_preference = self.user_preferences.joins('join preferences on preferences.id = user_preferences.preference_id')
                                            .where('preference_type_id = ?', preference_type.id).first
    if user_preference.nil?
      preference = Preference.create(:preference_type => preference_type, :preference_option => preference_option)
      UserPreference.create(:user => self, :preference => preference)
    else
      #do this to get around readonly record created by join
      user_preference = UserPreference.find(user_preference.id)
      user_preference.preference.preference_option = preference_option
      user_preference.preference.save
    end
  end
end
