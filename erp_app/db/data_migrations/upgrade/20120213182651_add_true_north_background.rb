class AddTrueNorthBackground
  
  def self.up
    truenorth_background_po = PreferenceOption.create(:description => 'TrueNorth Logo', :internal_identifier => 'truenorth_logo_background', :value => 'truenorth.png')
    
    desktop_backgroud_pt = PreferenceType.iid('desktop_background')
    desktop_backgroud_pt.preference_options << truenorth_background_po
    desktop_backgroud_pt.default_preference_option = truenorth_background_po
    desktop_backgroud_pt.save
  end
  
  def self.down
    PreferenceOption.iid('truenorth_logo_background').destroy
  end

end
