class FixApplicationStiIssue
  
  def self.up
    ValidPreferenceType.find(:all, :conditions => ["preferenced_record_type = ? or preferenced_record_type = ?", "DesktopApplication","OrganizerApplication"]).each do |valid_pref_type|
      valid_pref_type.preferenced_record_type = 'Application'
      valid_pref_type.save
    end
  end
  
  def self.down
    #remove data here
  end

end
