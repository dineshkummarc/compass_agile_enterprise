module ErpDevSvcs
  module ControllerSupport
    #calls a function sets up basic user auth so devise won't cause
    #our controller tests to fail.  It's my understanding that we have to actually
    #persist these to the DB in order to auth to work, so make sure to call this in
    #the "before(:each)" part of your examples so that the records are
    #cleaned up properly
    #
    #TODO: Make this method only available to controller tests
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
      @user = Factory.create(:user, :party => @party)
      sign_in @user
      @user
    end
  end
end
