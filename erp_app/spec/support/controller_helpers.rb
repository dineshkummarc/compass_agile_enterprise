def basic_user_auth
  @business_party_type = Factory.create(:individual)
  @party = Factory.create(:individual_party, :business_party => @business_party_type)

  @pref_opt1 = Factory.create(:preference_option)
  @pref_type1 = Factory.create(:preference_type)
  
  
  @pref_opt2 = Factory.create(:preference_option,
                 :description         => "Blue",
                 :internal_identifier => "blue_extjs_theme",
                 :value               => "ext-all.css")
  
  @pref_type2 = Factory.create(:preference_type,
                               :description         => "Theme",
                               :internal_identifier => "extjs_theme")
 
  #@request.env["devise.mapping"] = Devise.mappings[User.find(1)]
  @user = Factory.create(:user, :party_id => @party)
  sign_in @user
  @user
end
