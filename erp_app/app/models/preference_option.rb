class PreferenceOption < ActiveRecord::Base
  has_many   :preferences
  has_and_belongs_to_many :preference_type

  def self.iid( internal_identifier )
    find( :first, :conditions => [ 'internal_identifier = ?', internal_identifier.to_s ])
  end
end
