class Desktop < ActiveRecord::Base
  acts_as_app_container

  BACKGROUND_IMAGES_PATH = "#{Rails.root}/public/images/wallpaper"

  def shortcuts
    self.applications.select{|app| app.get_user_preference(self.user, :desktop_shortcut) === 'yes'}
  end

  def autoloads
    self.applications.select{|app| app.get_user_preference(self.user, :autoload_application) === 'yes'}
  end

  def setup_default_preferences
    #setup desktop background
    desktop_backgroud_pt = PreferenceType.iid('desktop_background')
    desktop_backgroud_pt.preferenced_records << self
    desktop_backgroud_pt.save

    pref = Preference.create(
      :preference_type => desktop_backgroud_pt,
      :preference_option => PreferenceOption.iid('portablemind_desktop_background')
    )

    self.user_preferences << UserPreference.create(
      :user => self.user,
      :preference => pref
    )

    #setup theme
    theme_pt = PreferenceType.iid('extjs_theme')
    theme_pt.preferenced_records << self
    theme_pt.save

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
    def add_background(description, image_data)
      result = {:success => true, :msg => nil}
      name = image_data.original_filename
      #make sure this is an image
      if name =~ /^.?[^\.]+\.(jpe?g|png|gif|tiff)$/
        #check to make sure this description is not already being used
        if PreferenceOption.iid(description.gsub(' ','').underscore + '_desktop_background').nil?
          #check the file does not already exist
          unless File.exists? File.join(BACKGROUND_IMAGES_PATH,name)
            if image_data.respond_to?(:read)
              contents = image_data.read
            elsif image_data.respond_to?(:path)
              contents = File.read(image_data.path)
            end
            FileUtils.mkdir_p(BACKGROUND_IMAGES_PATH) unless File.directory? BACKGROUND_IMAGES_PATH 
            File.open(File.join(BACKGROUND_IMAGES_PATH,name), 'wb'){|f| f.puts(contents)}
            pref_type = PreferenceType.iid('desktop_background')
            pref_type.preference_options << PreferenceOption.create(:description => description, :internal_identifier => (description.gsub(' ','').underscore + '_desktop_background'), :value => name)
            pref_type.save
          else
            result[:success] = false
            result[:msg] = 'Image file already exists'
          end
        else
          result[:success] = false
          result[:msg] = 'Description already used'
        end
      else
        result[:success] = false
        result[:msg] = 'Invalid file type. Must be an image'
      end

      result
    end

    def find_by_user(user)
      find_by_user_and_klass(user, Desktop)
    end
  end
  
end
