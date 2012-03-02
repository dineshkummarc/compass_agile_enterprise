class PreferenceType < ActiveRecord::Base
  has_many_polymorphic :preferenced_records,
               :through => :valid_preference_types,
               :models => [:app_containers, :desktops, :organizers, :applications]

  has_many    :preferences
  belongs_to  :default_preference_option, :foreign_key => 'default_pref_option_id', :class_name => 'PreferenceOption'
  has_and_belongs_to_many :preference_options
  
  alias :options :preference_options
  alias :default_option :default_preference_option

  def options_hash
    Hash[*self.preference_options.collect { |v|[v.internal_identifier, v.value]}.flatten]
  end

  def self.iid( internal_identifier )
    where('internal_identifier = ?', internal_identifier.to_s).first
  end

  def default_value
    default_preference_option.value
  end
  
end
