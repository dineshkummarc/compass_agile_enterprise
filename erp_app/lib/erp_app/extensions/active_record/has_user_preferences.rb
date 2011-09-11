module ErpApp
	module Extensions
		module ActiveRecord
			module HasUserPreferences

				def self.included(base)
				  base.extend(ClassMethods)
				end

				module ClassMethods

					def has_user_preferences()
						has_many :user_preferences, :as => :preferenced_record

						extend ErpApp::Extensions::ActiveRecord::HasUserPreferences::SingletonMethods
						include ErpApp::Extensions::ActiveRecord::HasUserPreferences::InstanceMethods
					end
				end

				module SingletonMethods
				end

				module InstanceMethods
				
				  def preferences(user)
					  self.user_preferences.includes([:preference]).where('user_id = ?', user.id).map(&:preference)
				  end

				  def set_user_preference(user, preference_type_iid, preference_option_lookup)
					  preference_type = PreferenceType.find_by_internal_identifier(preference_type_iid.to_s)
					  preference_option = nil
					  #preference option can be set using 
					  #:default [symbol which will set to default for preference type]
					  #:preference_option_iid [the internal identifier for the preference option]
					  #:value [the value of the preference_option]
					  if preference_option_lookup == :default
					    preference_option = preference_type.default_option
					  end

					  if preference_option.nil?
					    preference_option = preference_type.preference_options.where('internal_identifier = ?', preference_option_lookup.to_s).first
					  end

					  if preference_option.nil?
				 	    preference_option = preference_type.preference_options.find('value = ?', preference_option_lookup.to_s).first
					  end

					  if preference_option.nil?
					    raise 'Invalid option for preference type'
					  else
					    preference = find_user_preference(user, preference_type)
					    unless preference.nil?
						    preference.preference_option = preference_option
						    preference.save
  					  else
  						  preference = Preference.create(:preference_type => preference_type, :preference_option => preference_option)
  						  self.user_preferences << UserPreference.create(:preference => preference, :user => user)
  						  self.save
  					  end
  					end
				  end

				  def get_user_preference(user, preference_type_iid)
					preference_type = PreferenceType.find_by_internal_identifier(preference_type_iid.to_s)
					preference = find_user_preference(user, preference_type)
					if preference.nil?
					  preference_type.default_preference_option.value
					else
					  preference.preference_option.value
					end
				  end
				  
				  private

				  def find_user_preference(user, preference_type)
					preference = nil
					results = self.user_preferences.includes([:preference]).where('user_id = ? and preferences.preference_type_id = ?', user.id, preference_type.id)
					if !results.nil? && !results.empty?
					  preference = results.first.preference
					end
					preference
				  end
				end
			end
		end
	end
end
