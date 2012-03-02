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

      @business_party_type = FactoryGirl.create(:individual)
      @party = FactoryGirl.create(:individual_party, :business_party => @business_party_type)

      @pref_opt1 = FactoryGirl.create(:preference_option)
      @pref_type1 = FactoryGirl.create(:preference_type)


      @pref_opt2 = FactoryGirl.create(:preference_option,
                     :description         => "Blue",
                     :internal_identifier => "blue_extjs_theme",
                     :value               => "ext-all.css")

      @pref_type2 = FactoryGirl.create(:preference_type,
                                   :description         => "Theme",
                                   :internal_identifier => "extjs_theme")

      #@request.env["devise.mapping"] = Devise.mappings[User.find(1)]
      salt = 'asdasdastr4325234324sdfds'
      @user = FactoryGirl.create(:user, :party => @party,
        :salt => salt,
        :crypted_password => Sorcery::CryptoProviders::BCrypt.encrypt("password", salt),
        :activation_state => 'active')
      login_user(@user)
      
      @user
    end

    def basic_user_auth_with_admin
      @user = User.find_by_username('admin')
      login_user(@user)
    end
  end
end
