class FixForExtjsTheme
  
  def self.up
    #insert data here
    extjs_theme_pt = PreferenceType.find_by_internal_identifier('extjs_theme')
    User.all.each do |user|
      desktop = user.desktop
      puts extjs_theme_pt.id
      puts desktop.id
      unless extjs_theme_pt.preferenced_records.include?(desktop)
        puts "Updating ..."
        extjs_theme_pt.preferenced_records << desktop
        extjs_theme_pt.save
      end      
    end
  end
  
  def self.down
    #remove data here
  end

end
