class FixApplicationPreferences
  
  def self.up
    ValidPreferenceType.find(:all, :conditions => ["preferenced_record_type = ?", "Application"]).each do |valid_pref_type|
      valid_pref_type.preferenced_record_type = 'DesktopApplication'
      valid_pref_type.save
    end

  end
  
  def self.down
    #no need to go down
  end

end
