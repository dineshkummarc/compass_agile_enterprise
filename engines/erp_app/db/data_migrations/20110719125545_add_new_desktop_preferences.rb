class AddNewDesktopPreferences
  
  def self.up
    #insert data here
    unless PreferenceType.find_by_internal_identifier('extjs_theme').nil?
    
      extjs_theme_pt = PreferenceType.create(:description => 'Theme', :internal_identifier => 'extjs_theme')

      access_extjs_theme_po = PreferenceOption.create(:description => 'Access', :internal_identifier => 'access_extjs_theme', :value => 'ext-all-access.css')
      gray_extjs_theme_po = PreferenceOption.create(:description => 'Gray', :internal_identifier => 'gray_extjs_theme', :value => 'ext-all-gray.css')
      blue_extjs_theme_po = PreferenceOption.create(:description => 'Blue', :internal_identifier => 'blue_extjs_theme', :value => 'ext-all.css')

      extjs_theme_pt.preference_options << access_extjs_theme_po
      extjs_theme_pt.preference_options << gray_extjs_theme_po
      extjs_theme_pt.preference_options << blue_extjs_theme_po
      extjs_theme_pt.default_preference_option = blue_extjs_theme_po
      extjs_theme_pt.save

      #setup desktop theme
      User.all.each do |user|
        desktop = user.desktop

        pref = Preference.create(
          :preference_type => extjs_theme_pt,
          :preference_option => blue_extjs_theme_po
        )

        desktop.user_preferences << UserPreference.create(
          :user => user,
          :preference => pref
        )

        desktop.save
      end
    end
  end
  
  def self.down
    #remove data here
  end

end
